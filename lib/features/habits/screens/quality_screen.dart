import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';

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
        if (rated.isEmpty) return const Center(child: Text('Нет оценок'));
        return ListView.builder(
          itemCount: rated.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.star),
            title: Text(rated[i].title),
            trailing: Text('${rated[i].rating}'),
          ),
        );
      },
    );
  }
}
