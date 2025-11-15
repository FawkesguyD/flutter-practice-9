import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';
import 'package:prac5/features/habits/widgets/habit_tile.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsBloc, HabitsState>(
      builder: (context, state) {
        if (state is! HabitsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final rated = state.habits.where((h) => h.rating != null).toList()
          ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        if (rated.isEmpty) {
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const Text(
              'Нет оценок',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.red,
                decoration: TextDecoration.underline,
                decorationColor: Colors.yellow,
                decorationThickness: 6,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          itemCount: rated.length,
          itemBuilder: (_, i) => HabitTile(habit: rated[i]),
        );
      },
    );
  }
}
