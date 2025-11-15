import 'package:equatable/equatable.dart';
import 'package:prac5/features/habits/models/habit.dart';

abstract class HabitsState extends Equatable {
  const HabitsState();

  @override
  List<Object?> get props => [];
}

class HabitsInitial extends HabitsState {
  const HabitsInitial();
}

class HabitsLoading extends HabitsState {
  const HabitsLoading();
}

class HabitsLoaded extends HabitsState {
  final List<Habit> habits;

  const HabitsLoaded(this.habits);

  @override
  List<Object?> get props => [habits];

  int get totalHabits => habits.length;
  int get doneHabits => habits.where((h) => h.isRead).length;
  int get plannedHabits => totalHabits - doneHabits;

  double get averageRating {
    final rated = habits.where((h) => h.rating != null);
    if (rated.isEmpty) return 0.0;
    final sum = rated.map((h) => h.rating!).reduce((a, b) => a + b);
    return sum / rated.length;
  }

  List<Habit> get recentHabits {
    if (habits.isEmpty) return [];
    final sorted = habits.toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sorted.take(3).toList();
  }

  List<Habit> get doneHabitsList => habits.where((h) => h.isRead).toList();
  List<Habit> get plannedHabitsList => habits.where((h) => !h.isRead).toList();
}

class HabitsError extends HabitsState {
  final String message;
  const HabitsError(this.message);

  @override
  List<Object?> get props => [message];
}
