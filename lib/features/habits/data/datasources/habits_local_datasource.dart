import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prac5/features/habits/models/habit.dart';
import 'package:prac5/services/logger_service.dart';

class HabitsLocalDataSource {
  static const String _habitsKey = 'habits_data';

  Future<List<Habit>> getHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? habitsJson = prefs.getString(_habitsKey);

      if (habitsJson == null || habitsJson.isEmpty) {
        LoggerService.info('HabitsLocalDataSource: пустой список');
        return [];
      }

      final List<dynamic> decoded = json.decode(habitsJson);
      final habits = decoded.map((json) => _habitFromJson(json)).toList();

      LoggerService.info(
        'HabitsLocalDataSource: загружено ${habits.length} элементов',
      );
      return habits;
    } catch (e) {
      LoggerService.error('HabitsLocalDataSource: ошибка загрузки: $e');
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = json.encode(
        habits.map((h) => _habitToJson(h)).toList(),
      );
      await prefs.setString(_habitsKey, habitsJson);

      LoggerService.info(
        'HabitsLocalDataSource: сохранено ${habits.length} элементов',
      );
    } catch (e) {
      LoggerService.error('HabitsLocalDataSource: ошибка сохранения: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _habitToJson(Habit h) => {
    'id': h.id,
    'title': h.title,
    'author': h.author,
    'genre': h.genre,
    'description': h.description,
    'pages': h.pages,
    'isRead': h.isRead,
    'rating': h.rating,
    'dateAdded': h.dateAdded.toIso8601String(),
    'dateFinished': h.dateFinished?.toIso8601String(),
    'imageUrl': h.imageUrl,
  };

  Habit _habitFromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    genre: json['genre'] as String,
    description: json['description'] as String?,
    pages: json['pages'] as int?,
    isRead: json['isRead'] as bool? ?? false,
    rating: json['rating'] as int?,
    dateAdded: DateTime.parse(json['dateAdded'] as String),
    dateFinished: json['dateFinished'] != null
        ? DateTime.parse(json['dateFinished'] as String)
        : null,
    imageUrl: json['imageUrl'] as String?,
  );
}
