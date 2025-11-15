import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          final ratedCount =
              state.habits.where((h) => h.rating != null).length;

          final progress = total == 0 ? 0.0 : done / total;

          final Map<String, int> byGenre = {};
          for (final h in state.habits) {
            byGenre[h.genre] = (byGenre[h.genre] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionCard(
                context,
                icon: Icons.trending_up,
                title: 'Общий прогресс',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                icon: Icons.insert_chart_outlined,
                title: 'Сводка',
                child: Column(
                  children: [
                    _statRow('Всего привычек', '$total'),
                    _statRow('Выполнено', '$done'),
                    _statRow('Запланировано', '$planned'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                icon: Icons.star_border,
                title: 'Качество выполнения',
                child: Column(
                  children: [
                    _statRow(
                      'Среднее качество',
                      ratedCount == 0 ? '—' : avg.toStringAsFixed(1),
                    ),
                    _statRow('Оценено выполнений', '$ratedCount'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                icon: Icons.category_outlined,
                title: 'По категориям',
                child: Column(
                  children: byGenre.entries
                      .map(
                        (e) => _statRow(e.key, e.value.toString()),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
