import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/views/areas/create/page.dart';
import 'package:marine_analytics_platform/presentation/views/department/page.dart';
import 'package:marine_analytics_platform/presentation/views/history_page.dart';
import 'package:marine_analytics_platform/presentation/views/home.dart';
import 'package:marine_analytics_platform/presentation/views/intro.dart';
import 'package:marine_analytics_platform/presentation/views/login/page.dart';
import 'package:marine_analytics_platform/presentation/views/register/page.dart';
import 'package:marine_analytics_platform/presentation/views/setting.dart';
import 'package:marine_analytics_platform/presentation/views/waste_type/page.dart';

final appRouter = GoRouter(
  redirect: (context, state) {
    final currentSession = supabase.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login';
    final isRegistering = state.matchedLocation == '/register';

    if (currentSession == null) {
      if (!isLoggingIn && !isRegistering) {
        return '/login';
      }
      return state.fullPath;
    }

    if (isLoggingIn || isRegistering) {
      return '/';
    }

    return null;
  },
  initialLocation: '/',
  routes: [
    GoRoute(path: '/intro', builder: (context, state) => IntroView()),
    GoRoute(path: '/department', name: '/department', builder: (context, state) => DepartmentPage()),
    GoRoute(path: '/wasteType', name: '/wasteType', builder: (context, state) => WasteTypePage()),
    GoRoute(path: '/create/area', name: '/create/area', builder: (context, state) => CreateAreaPage()),
    GoRoute(path: '/login', name: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/register', name: '/register', builder: (context, state) => RegisterPage()),
    ShellRoute(
      builder: (context, state, child) {
        int currentIndex = 0;
        final location = state.uri.toString();
        if (location.startsWith('/ships')) {
          currentIndex = 1;
        } else if (location.startsWith('/settings')) {
          currentIndex = 2;
        }
        void goToTab(int index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/ships');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        }
        // ===========================================

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: goToTab,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.directions_boat), label: "Ships"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
            ],
          ),
        );
      },
      routes: [
        GoRoute(name: '/', path: '/', builder: (_, __) => const HomePage()),
        GoRoute(path: '/ships', builder: (_, __) => const HistoryPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);
