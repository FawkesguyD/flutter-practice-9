import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:prac5/features/habits/widgets/habit_tile.dart';
import 'package:prac5/features/habits/bloc/habits_bloc.dart';
import 'package:prac5/features/habits/bloc/habits_event.dart';
import 'package:prac5/features/habits/bloc/habits_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddHabitDialog(BuildContext context) {
    context.push(
      '/habit-form',
      extra: {
        'onSave': (habit) {
          context.read<HabitsBloc>().add(AddHabit(habit));
          context.pop();
        },
      },
    );
  }

  void _openProfile(BuildContext context) {
    context.push('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          if (state is HabitsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HabitsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          if (state is! HabitsLoaded) {
            return const Center(child: Text('Нет данных'));
          }

          final total = state.totalHabits;
          final done = state.doneHabits;
          final planned = state.plannedHabits;
          final avg = state.averageRating;
          final recent = state.recentHabits;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                floating: true,
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Трекер привычек',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () => _openProfile(context),
                        tooltip: 'Профиль',
                      ),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => context.push('/my-collection'),
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.task_alt,
                                color: colorScheme.onPrimary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Мои привычки',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$total ${_habitsWord(total)}',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Статистика',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Вертикальный список карточек статистики
                      _buildStatCard(
                        context: context,
                        icon: Icons.check_circle_outline,
                        value: done.toString(),
                        label: 'Выполнено',
                        color: Colors.grey,
                        onTap: () => context.push('/done'),
                      ),

                      const SizedBox(height: 12),

                      _buildStatCard(
                        context: context,
                        icon: Icons.schedule_outlined,
                        value: planned.toString(),
                        label: 'Запланировано',
                        color: Colors.grey,
                        onTap: () => context.push('/planned'),
                      ),

                      const SizedBox(height: 12),

                      _buildStatCard(
                        context: context,
                        icon: Icons.star_outline,
                        value: avg.toStringAsFixed(1),
                        label: 'Качество выполнения',
                        color: Colors.grey,
                        onTap: () => context.push('/ratings'),
                      ),

                      const SizedBox(height: 12),

                      _buildStatCard(
                        context: context,
                        icon: Icons.trending_up,
                        value:
                            '${(total > 0 ? (done / total * 100) : 0).toStringAsFixed(0)}%',
                        label: 'Прогресс',
                        color: Colors.grey,
                        onTap: () => context.push('/statistics'),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Недавние привычки',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (recent.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 80,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Пока нет привычек',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Добавьте привычки в свой список',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final habit = recent[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HabitTile(key: ValueKey(habit.id), habit: habit),
                      );
                    }, childCount: recent.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        tooltip: 'Добавить привычку',
        child: const Icon(Icons.playlist_add_check),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _habitsWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'привычка';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'привычки';
    } else {
      return 'привычек';
    }
  }
}
