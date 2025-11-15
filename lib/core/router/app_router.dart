import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prac5/core/di/service_locator.dart';
import 'package:prac5/features/auth/auth_screen.dart';
import 'package:prac5/features/habits/screens/home_screen.dart';
import 'package:prac5/features/habits/screens/done_habits_screen.dart';
import 'package:prac5/features/habits/screens/planned_habits_screen.dart';
import 'package:prac5/features/habits/screens/all_habits_screen.dart';
import 'package:prac5/features/habits/screens/habit_detail_screen.dart';
import 'package:prac5/features/habits/screens/habit_form_screen.dart';
import 'package:prac5/features/habits/screens/my_collection_screen.dart';
import 'package:prac5/features/habits/screens/quality_screen.dart';
import 'package:prac5/features/habits/screens/statistics_screen.dart';
import 'package:prac5/features/profile/profile_screen.dart';
import 'package:prac5/features/habits/models/habit.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = await Services.auth.isLoggedIn();
      final isGoingToAuth = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isGoingToAuth) {
        return '/auth';
      }

      if (isLoggedIn && isGoingToAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/done',
        name: 'done-habits',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Выполненные привычки')),
          body: const DoneHabitsScreen(),
        ),
      ),
      GoRoute(
        path: '/planned',
        name: 'planned-habits',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Запланированные привычки')),
          body: const PlannedHabitsScreen(),
        ),
      ),
      GoRoute(
        path: '/all',
        name: 'all-habits',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Все привычки')),
          body: const AllHabitsScreen(),
        ),
      ),
      GoRoute(
        path: '/my-collection',
        name: 'my-collection',
        builder: (context, state) => const MyCollectionScreen(),
      ),
      GoRoute(
        path: '/ratings',
        name: 'ratings',
        builder: (context, state) => const QualityScreen(),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/habit/:id',
        name: 'habit-detail',
        builder: (context, state) {
          final habit = state.extra as Habit;
          return HabitDetailScreen(habit: habit);
        },
      ),
      GoRoute(
        path: '/habit-form',
        name: 'habit-form',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>?;
          final onSave = params?['onSave'] as Function(Habit)?;
          final habit = params?['habit'] as Habit?;

          return HabitFormScreen(onSave: onSave ?? (h) {}, habit: habit);
        },
      ),
    ],
  );
}
