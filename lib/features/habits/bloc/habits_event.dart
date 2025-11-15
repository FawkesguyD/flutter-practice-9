import 'package:equatable/equatable.dart';
import 'package:prac5/features/habits/models/habit.dart';

abstract class HabitsEvent extends Equatable {
  const HabitsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabits extends HabitsEvent {
  const LoadHabits();
}

class AddHabit extends HabitsEvent {
  final Habit habit;

  const AddHabit(this.habit);

  @override
  List<Object?> get props => [habit];
}

class UpdateHabit extends HabitsEvent {
  final Habit habit;

  const UpdateHabit(this.habit);

  @override
  List<Object?> get props => [habit];
}

class DeleteHabit extends HabitsEvent {
  final String habitId;

  const DeleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class ToggleHabitDone extends HabitsEvent {
  final String habitId;
  final bool isDone;

  const ToggleHabitDone(this.habitId, this.isDone);

  @override
  List<Object?> get props => [habitId, isDone];
}

class RateHabit extends HabitsEvent {
  final String habitId;
  final int? rating; // null = remove rating

  const RateHabit(this.habitId, this.rating);

  @override
  List<Object?> get props => [habitId, rating];
}
