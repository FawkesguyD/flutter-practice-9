import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';

class PlannedHabitsScreen extends StatelessWidget {
  const PlannedHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitsBloc, HabitsState>(
      builder: (context, state) {
        if (state is! HabitsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = state.plannedHabitsList;
        if (items.isEmpty) {
          return const Center(child: Text('Планов нет'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(items[i].title),
            subtitle: Text(items[i].author),
          ),
        );
      },
    );
  }
}
