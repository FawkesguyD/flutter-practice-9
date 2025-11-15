import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';
import 'package:prac5/features/habits/widgets/habit_tile.dart';

class DoneHabitsScreen extends StatelessWidget {
  const DoneHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsBloc, HabitsState>(
      builder: (context, state) {
        if (state is! HabitsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = state.doneHabitsList;
        if (items.isEmpty) {
          return const Center(child: Text('Нет выполненных привычек'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => HabitTile(habit: items[i]),
        );
      },
    );
  }
}
