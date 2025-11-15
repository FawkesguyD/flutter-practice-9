import 'package:prac5/features/habits/models/habit.dart';
import 'package:prac5/features/habits/data/repositories/habits_repository.dart';
import 'package:prac5/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:prac5/services/logger_service.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsLocalDataSource _localDataSource;

  HabitsRepositoryImpl({required HabitsLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<List<Habit>> getHabits() async {
    try {
      return await _localDataSource.getHabits();
    } catch (e) {
      LoggerService.error('HabitsRepository: ошибка получения: $e');
      rethrow;
    }
  }

  @override
  Future<void> addHabit(Habit habit) async {
    try {
      final habits = await getHabits();
      habits.add(habit);
      await _localDataSource.saveHabits(habits);
      LoggerService.info(
        'HabitsRepository: добавлена привычка: ${habit.title}',
      );
    } catch (e) {
      LoggerService.error('HabitsRepository: ошибка добавления: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    try {
      final habits = await getHabits();
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
        await _localDataSource.saveHabits(habits);
        LoggerService.info(
          'HabitsRepository: обновлена привычка: ${habit.title}',
        );
      } else {
        throw Exception('Привычка с ID ${habit.id} не найдена');
      }
    } catch (e) {
      LoggerService.error('HabitsRepository: ошибка обновления: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      final habits = await getHabits();
      habits.removeWhere((h) => h.id == id);
      await _localDataSource.saveHabits(habits);
      LoggerService.info('HabitsRepository: удалена привычка: $id');
    } catch (e) {
      LoggerService.error('HabitsRepository: ошибка удаления: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveHabits(List<Habit> habits) async {
    try {
      await _localDataSource.saveHabits(habits);
    } catch (e) {
      LoggerService.error('HabitsRepository: ошибка сохранения: $e');
      rethrow;
    }
  }
}
