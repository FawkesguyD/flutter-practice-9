import 'package:get_it/get_it.dart';
import 'package:prac5/services/image_service.dart';
import 'package:prac5/services/profile_service.dart';
import 'package:prac5/services/auth_service.dart';
import 'package:prac5/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:prac5/features/habits/data/repositories/habits_repository.dart';
import 'package:prac5/features/habits/data/repositories/habits_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<HabitsLocalDataSource>(HabitsLocalDataSource());

  getIt.registerSingleton<HabitsRepository>(
    HabitsRepositoryImpl(localDataSource: getIt<HabitsLocalDataSource>()),
  );

  getIt.registerSingleton<ImageService>(ImageService());

  await getIt<ImageService>().initialize();

  getIt.registerSingleton<ProfileService>(ProfileService());

  getIt.registerSingleton<AuthService>(AuthService());
}

class Services {
  static ImageService get image => getIt<ImageService>();
  static ProfileService get profile => getIt<ProfileService>();
  static AuthService get auth => getIt<AuthService>();
}

class Repositories {
  static HabitsRepository get habits => getIt<HabitsRepository>();
}
