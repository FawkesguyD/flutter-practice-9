import 'package:shared_preferences/shared_preferences.dart';
import 'package:prac5/core/di/service_locator.dart';

class UserProfile {
  final String id;
  String nickname;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatarUrl': avatarUrl,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    nickname: json['nickname'],
    avatarUrl: json['avatarUrl'],
  );
}

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _keyUserId = 'user_id';
  static const String _keyNickname = 'user_nickname';
  static const String _keyAvatarUrl = 'user_avatar_url';

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString(_keyUserId);
    String? nickname = prefs.getString(_keyNickname);
    String? avatarUrl = prefs.getString(_keyAvatarUrl);

    if (userId == null) {
      userId = DateTime.now().millisecondsSinceEpoch.toString();

      // try use registered username as display name
      final registered = await Services.auth.getUsername();
      nickname = (registered != null && registered.trim().isNotEmpty)
          ? registered.trim()
          : 'Аккаунт';

      // Используем локальный аватар из assets как дефолт
      avatarUrl = 'assets/avatar.png';

      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyNickname, nickname);
      await prefs.setString(_keyAvatarUrl, avatarUrl);
    }

    // Migrate old defaults to username or generic label
    if (nickname == 'Читатель' ||
        nickname == 'Р§РёС‚Р°С‚РµР»СЊ' ||
        nickname == 'Повар' ||
        nickname == 'Аккаунт') {
      final registered = await Services.auth.getUsername();
      nickname = (registered != null && registered.trim().isNotEmpty)
          ? registered.trim()
          : 'Аккаунт';
      await prefs.setString(_keyNickname, nickname);
    }

    // Гарантируем локальный аватар для всех пользователей
    if (avatarUrl != 'assets/avatar.png') {
      avatarUrl = 'assets/avatar.png';
      await prefs.setString(_keyAvatarUrl, avatarUrl);
    }

    return UserProfile(
      id: userId,
      nickname: nickname ?? 'Аккаунт',
      avatarUrl: avatarUrl ?? 'assets/avatar.png',
    );
  }

  Future<void> updateNickname(String newNickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, newNickname);
  }

  Future<void> updateAvatar(String newAvatarUrl) async {
    // Игнорируем внешние URL — всегда сохраняем локальный аватар
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAvatarUrl, 'assets/avatar.png');
  }
}
