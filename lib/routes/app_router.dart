import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/presentation/views/areas/create/page.dart';
import 'package:marine_analytics_platform/presentation/views/home.dart';
import 'package:marine_analytics_platform/presentation/views/intro.dart';
import 'package:marine_analytics_platform/presentation/views/setting.dart';
import 'package:marine_analytics_platform/presentation/views/ship_list_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/intro', builder: (context, state) => IntroView()),
    GoRoute(path: '/create/area', name: '/create/area', builder: (context, state) => CreateAreaPage()),
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
        GoRoute(path: '/ships', builder: (_, __) => const ShipListView()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);
