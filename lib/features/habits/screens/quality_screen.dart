import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';
import 'package:prac5/features/habits/widgets/habit_tile.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Должное выполнение')),
      body: BlocBuilder<HabitsBloc, HabitsState>(
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

          final avg = state.averageRating;
          final highQuality =
              rated.where((h) => (h.rating ?? 0) >= 4).length;
          final doneCount = rated.where((h) => h.isRead).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _summaryItem(
                        icon: Icons.star_border,
                        label: 'Среднее качество',
                        value: avg.toStringAsFixed(1),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      _summaryItem(
                        icon: Icons.thumb_up_alt_outlined,
                        label: 'Высокое (4–5)',
                        value: '$highQuality',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      _summaryItem(
                        icon: Icons.check_circle_outline,
                        label: 'Выполнено',
                        value: '$doneCount',
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: rated.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HabitTile(habit: rated[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
