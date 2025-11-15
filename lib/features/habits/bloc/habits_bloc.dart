import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_event.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';
import 'package:prac5/features/habits/models/habit.dart';
import 'package:prac5/features/habits/data/repositories/habits_repository.dart';
import 'package:prac5/core/di/service_locator.dart';
import 'package:prac5/services/logger_service.dart';

class HabitsBloc extends Bloc<HabitsEvent, HabitsState> {
  final HabitsRepository _repository;

  HabitsBloc({required HabitsRepository repository})
    : _repository = repository,
      super(const HabitsInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
    on<ToggleHabitDone>(_onToggleHabitDone);
    on<RateHabit>(_onRateHabit);
  }

  Future<void> _onLoadHabits(
    LoadHabits event,
    Emitter<HabitsState> emit,
  ) async {
    try {
      emit(const HabitsLoading());
      final habits = await _repository.getHabits();
      emit(HabitsLoaded(habits));
      LoggerService.info('Загружено привычек: ${habits.length}');
    } catch (e) {
      LoggerService.error('Ошибка загрузки привычек: $e');
      emit(HabitsError('Не удалось загрузить привычки: $e'));
    }
  }

  Future<void> _onAddHabit(AddHabit event, Emitter<HabitsState> emit) async {
    try {
      if (state is HabitsLoaded) {
        final currentState = state as HabitsLoaded;

        final asset = Services.image.assetForGenre(
          event.habit.genre,
          title: event.habit.title,
        );
        final imageUrl = asset ?? await Services.image.getNextRecipeImage();
        final withImage = event.habit.copyWith(imageUrl: imageUrl);

        await _repository.addHabit(withImage);

        final updated = List<Habit>.from(currentState.habits)..add(withImage);
        emit(HabitsLoaded(updated));
        LoggerService.info('Добавлена привычка: ${withImage.title}');
      }
    } catch (e) {
      LoggerService.error('Ошибка добавления привычки: $e');
      emit(HabitsError('Не удалось добавить привычку: $e'));
    }
  }

  Future<void> _onUpdateHabit(
    UpdateHabit event,
    Emitter<HabitsState> emit,
  ) async {
    try {
      if (state is HabitsLoaded) {
        final currentState = state as HabitsLoaded;
        await _repository.updateHabit(event.habit);
        final updated = currentState.habits
            .map((h) => h.id == event.habit.id ? event.habit : h)
            .toList();
        emit(HabitsLoaded(updated));
        LoggerService.info('Обновлена привычка: ${event.habit.title}');
      }
    } catch (e) {
      LoggerService.error('Ошибка обновления привычки: $e');
      emit(HabitsError('Не удалось обновить привычку: $e'));
    }
  }

  Future<void> _onDeleteHabit(
    DeleteHabit event,
    Emitter<HabitsState> emit,
  ) async {
    try {
      if (state is HabitsLoaded) {
        final currentState = state as HabitsLoaded;
        final toDelete = currentState.habits.firstWhere(
          (h) => h.id == event.habitId,
        );

        if (toDelete.imageUrl != null) {
          await Services.image.releaseImage(toDelete.imageUrl!);
        }

        await _repository.deleteHabit(event.habitId);
        final updated = currentState.habits
            .where((h) => h.id != event.habitId)
            .toList();
        emit(HabitsLoaded(updated));
        LoggerService.info('Удалена привычка: ${toDelete.title}');
      }
    } catch (e) {
      LoggerService.error('Ошибка удаления привычки: $e');
      emit(HabitsError('Не удалось удалить привычку: $e'));
    }
  }

  Future<void> _onToggleHabitDone(
    ToggleHabitDone event,
    Emitter<HabitsState> emit,
  ) async {
    try {
      if (state is HabitsLoaded) {
        final currentState = state as HabitsLoaded;
        final updated = currentState.habits.map((h) {
          if (h.id == event.habitId) {
            return h.copyWith(
              isRead: event.isDone,
              dateFinished: event.isDone ? DateTime.now() : null,
            );
          }
          return h;
        }).toList();
        final changed = updated.firstWhere((h) => h.id == event.habitId);
        await _repository.updateHabit(changed);
        emit(HabitsLoaded(updated));
        LoggerService.info('Статус изменен для ID: ${event.habitId}');
      }
    } catch (e) {
      LoggerService.error('Ошибка смены статуса: $e');
      emit(HabitsError('Не удалось изменить статус: $e'));
    }
  }

  Future<void> _onRateHabit(RateHabit event, Emitter<HabitsState> emit) async {
    try {
      if (state is HabitsLoaded) {
        final currentState = state as HabitsLoaded;
        final updated = currentState.habits.map((h) {
          if (h.id == event.habitId) {
            return h.copyWith(rating: event.rating);
          }
          return h;
        }).toList();
        final changed = updated.firstWhere((h) => h.id == event.habitId);
        await _repository.updateHabit(changed);
        emit(HabitsLoaded(updated));
        LoggerService.info(
          'Качество изменено для ID: ${event.habitId}, новая: ${event.rating}',
        );
      }
    } catch (e) {
      LoggerService.error('Ошибка изменения качества: $e');
      emit(HabitsError('Не удалось изменить качество: $e'));
    }
  }
}
