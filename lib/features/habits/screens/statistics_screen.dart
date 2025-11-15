import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          if (state is! HabitsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final total = state.totalHabits;
          final done = state.doneHabits;
          final planned = state.plannedHabits;
          final avg = state.averageRating;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tile('Всего привычек', '$total'),
              _tile('Выполнено', '$done'),
              _tile('Запланировано', '$planned'),
              _tile('Среднее качество', avg.toStringAsFixed(1)),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(String label, String value) => ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}
