import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';
import 'package:prac5/features/habits/widgets/habit_tile.dart';

class MyCollectionScreen extends StatelessWidget {
  const MyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои привычки')),
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          if (state is HabitsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! HabitsLoaded) {
            return const Center(child: Text('Ошибка загрузки'));
          }

          final habits = state.habits;

          if (habits.isEmpty) {
            return const Center(child: Text('Список пуст'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final h = habits[index];
              return HabitTile(habit: h);
            },
          );
        },
      ),
    );
  }
}
