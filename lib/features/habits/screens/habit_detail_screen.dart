import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_event.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';
import 'package:prac5/features/habits/models/habit.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали привычки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editHabit(context),
            tooltip: 'Редактировать',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Удалить',
          ),
        ],
      ),
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          Habit? current = habit;

          if (state is HabitsLoaded) {
            final found = state.habits.where((h) => h.id == habit.id);
            if (found.isNotEmpty) {
              current = found.first;
            } else {
              current = null;
            }
          }

          if (current == null) {
            return const Center(
              child: Text('Привычка не найдена'),
            );
          }

          final isDone = current.isRead;
          final dateFormat = DateFormat('dd.MM.yyyy');

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderImage(context, current, isDone),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isDone
                                ? [
                                    Colors.green.shade400,
                                    Colors.green.shade600,
                                  ]
                                : [
                                    Colors.orange.shade400,
                                    Colors.orange.shade600,
                                  ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: Icon(
                                isDone ? Icons.check : Icons.schedule,
                                color:
                                    isDone ? Colors.green.shade600 : Colors.orange.shade600,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              current.title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              current.author,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(
                                  icon: Icons.category_outlined,
                                  label: 'Категория',
                                  value: current.genre,
                                ),
                                const SizedBox(height: 12),
                                _infoRow(
                                  icon: Icons.timer_outlined,
                                  label: 'Длительность (мин)',
                                  value: current.pages?.toString() ?? '—',
                                ),
                                const SizedBox(height: 12),
                                _infoRow(
                                  icon: Icons.event_note_outlined,
                                  label: 'Добавлено',
                                  value: dateFormat.format(current.dateAdded),
                                ),
                                const SizedBox(height: 12),
                                _infoRow(
                                  icon: Icons.check_circle_outline,
                                  label: 'Выполнено',
                                  value: current.dateFinished != null
                                      ? dateFormat.format(current.dateFinished!)
                                      : '—',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isDone
                              ? () {
                                  context.read<HabitsBloc>().add(
                                        ToggleHabitDone(current!.id, false),
                                      );
                                }
                              : null,
                          icon: const Icon(Icons.undo),
                          label: const Text('Вернуть в список'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showRatingSheet(context, current!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          icon: const Icon(Icons.star),
                          label: Text(
                            current.rating == null
                                ? 'Оценить'
                                : 'Изменить оценку',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, Habit habit, bool isDone) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (habit.imageUrl != null)
            ClipRRect(
              child: habit.imageUrl!.startsWith('assets/')
                  ? Image.asset(
                      habit.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      imageUrl: habit.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDone ? Colors.green.shade400 : Colors.orange.shade400,
                              isDone ? Colors.green.shade700 : Colors.orange.shade700,
                            ],
                          ),
                        ),
                      ),
                    ),
            )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDone ? Colors.green.shade400 : Colors.orange.shade400,
                    isDone ? Colors.green.shade700 : Colors.orange.shade700,
                  ],
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Chip(
              label: Text(
                habit.genre,
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
              avatar: const Icon(Icons.local_activity, size: 18),
              backgroundColor: colorScheme.secondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _editHabit(BuildContext context) {
    context.push(
      '/habit-form',
      extra: {
        'habit': habit,
        'onSave': (Habit updated) {
          context.read<HabitsBloc>().add(UpdateHabit(updated));
          context.pop();
        },
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content:
            Text('Вы уверены, что хотите удалить "${habit.title}" из списка?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<HabitsBloc>().add(DeleteHabit(habit.id));
      context.pop();
    }
  }

  void _showRatingSheet(BuildContext context, Habit habit) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        int? selected = habit.rating;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Оцените выполнение',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      final isActive = (selected ?? 0) >= value;
                      return IconButton(
                        icon: Icon(
                          isActive ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selected = value;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          context
                              .read<HabitsBloc>()
                              .add(RateHabit(habit.id, null));
                          Navigator.pop(context);
                        },
                        child: const Text('Сбросить оценку'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<HabitsBloc>()
                              .add(RateHabit(habit.id, selected ?? 1));
                          Navigator.pop(context);
                        },
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
