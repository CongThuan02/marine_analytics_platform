import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/views/alerts/page.dart';
import 'package:marine_analytics_platform/presentation/views/alerts/create_test_alert_page.dart';
import 'package:marine_analytics_platform/presentation/views/test_local_notification_page.dart';
import 'package:marine_analytics_platform/presentation/views/test_reminder_notification_page.dart';
import 'package:marine_analytics_platform/presentation/views/areas/create/page.dart';
import 'package:marine_analytics_platform/presentation/views/qr_code_page.dart';
import 'package:marine_analytics_platform/test_supabase_connection.dart';
import 'package:marine_analytics_platform/presentation/views/department/page.dart';
import 'package:marine_analytics_platform/presentation/views/history_page.dart';
import 'package:marine_analytics_platform/presentation/views/home.dart';
import 'package:marine_analytics_platform/presentation/views/intro.dart';
import 'package:marine_analytics_platform/presentation/views/login/page.dart';
import 'package:marine_analytics_platform/presentation/views/register/page.dart';
import 'package:marine_analytics_platform/presentation/views/reminder/page.dart';
import 'package:marine_analytics_platform/presentation/views/setting.dart';
import 'package:marine_analytics_platform/presentation/views/splash_screen.dart';
import 'package:marine_analytics_platform/presentation/views/waste_limit/page.dart';
import 'package:marine_analytics_platform/presentation/views/waste_type/page.dart';

final appRouter = GoRouter(
  observers: [RouteObserver()],
  redirect: (context, state) {
    // Log current route
    print('🔹 Current Route: ${state.matchedLocation}');
    print('🔹 Full Path: ${state.fullPath}');
    print('🔹 Path Parameters: ${state.pathParameters}');
    print('🔹 Query Parameters: ${state.uri.queryParameters}');
    print('---');

    // Allow splash screen
    if (state.matchedLocation == '/splash') {
      return null;
    }

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
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/intro', builder: (context, state) => IntroView()),

    GoRoute(path: '/department', name: '/department', builder: (context, state) => DepartmentPage()),
    GoRoute(path: '/wasteType', name: '/wasteType', builder: (context, state) => WasteTypePage()),
    GoRoute(path: '/wasteLimit', name: '/wasteLimit', builder: (context, state) => const WasteLimitPage()),
    GoRoute(path: '/reminder', name: '/reminder', builder: (context, state) => const ReminderPage()),
    GoRoute(path: '/alerts', name: '/alerts', builder: (context, state) => const AlertsPage()),
    GoRoute(path: '/alerts/test', name: '/alerts/test', builder: (context, state) => const CreateTestAlertPage()),
    GoRoute(
      path: '/test-connection',
      name: '/test-connection',
      builder: (context, state) => const TestSupabaseConnectionPage(),
    ),
    GoRoute(
      path: '/test-local-notification',
      name: '/test-local-notification',
      builder: (context, state) => const TestLocalNotificationPage(),
    ),
    GoRoute(
      path: '/test-reminder-notification',
      name: '/test-reminder-notification',
      builder: (context, state) => const TestReminderNotificationPage(),
    ),
    GoRoute(path: '/qr-code', name: '/qr-code', builder: (context, state) => const QRCodePage()),
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Tổng quan"),
              BottomNavigationBarItem(icon: Icon(Icons.directions_boat), label: "Lịch sử"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Cài đặt"),
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
