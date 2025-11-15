import 'package:prac5/features/habits/models/habit.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> saveHabits(List<Habit> habits);
}
