import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:prac5/features/habits/models/habit.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_event.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;

  const HabitTile({super.key, required this.habit});

  void _toggleFavorite(BuildContext context) {
    final newRating = (habit.rating == null || habit.rating == 0) ? 5 : null;
    context.read<HabitsBloc>().add(RateHabit(habit.id, newRating));
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content: Text('Вы уверены, что хотите удалить "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<HabitsBloc>().add(DeleteHabit(habit.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    context.push('/habit/${habit.id}', extra: habit);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  if (habit.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: habit.imageUrl!.startsWith('assets/')
                          ? Image.asset(
                              habit.imageUrl!,
                              width: 60,
                              height: 85,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: habit.imageUrl!,
                              width: 60,
                              height: 85,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 60,
                                height: 85,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 60,
                                height: 85,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      habit.isRead
                                          ? Colors.green.shade400
                                          : Colors.orange.shade400,
                                      habit.isRead
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.task_alt,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            habit.isRead
                                ? Colors.green.shade400
                                : Colors.orange.shade400,
                            habit.isRead
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.task_alt,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 32,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: habit.isRead ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        habit.isRead ? Icons.check : Icons.schedule,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: habit.isRead
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.author,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            habit.genre,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                        if (habit.rating != null) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                habit.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      habit.isRead ? Icons.undo : Icons.check_circle_outline,
                      color: habit.isRead ? Colors.grey : Colors.green,
                    ),
                    onPressed: () => context
                        .read<HabitsBloc>()
                        .add(ToggleHabitDone(habit.id, !habit.isRead)),
                    tooltip: habit.isRead ? 'Отменить' : 'Выполнено',
                  ),
                  IconButton(
                    icon: Icon(
                      habit.rating == null || habit.rating == 0
                          ? Icons.star_border
                          : Icons.star,
                      color: Colors.amber,
                    ),
                    onPressed: () => _toggleFavorite(context),
                    tooltip: (habit.rating == null || habit.rating == 0)
                        ? 'В избранное'
                        : 'Убрать из избранного',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context),
                    tooltip: 'Удалить',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
