import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/core/di/injection_container.dart'
    as di;
import 'package:marine_analytics_platform/core/services/fcm_service.dart';
import 'package:marine_analytics_platform/core/services/local_notification_service.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/firebase_options.dart';
import 'package:marine_analytics_platform/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'global.dart';

/// --- Deep link handler Flutter-native ---
class DeepLinkService with WidgetsBindingObserver {
  static final DeepLinkService _instance = DeepLinkService._();
  DeepLinkService._();
  factory DeepLinkService() => _instance;

  String? lastLink;
  final StreamController<Uri> _linkStream = StreamController.broadcast();

  Stream<Uri> get stream => _linkStream.stream;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _getInitialLink();
  }

  Future<void> _getInitialLink() async {
    try {
      final uriString =
          WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (uriString != "/") {
        final uri = Uri.parse(uriString);
        lastLink = uriString;
        _linkStream.add(uri);
      }
    } catch (e) {
      print("Initial link error: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      final uriString =
          WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (uriString != lastLink && uriString != "/") {
        final uri = Uri.parse(uriString);
        lastLink = uriString;
        _linkStream.add(uri);
      }
    } catch (_) {}
  }
}

/// Initialize deep link and listen
Future<void> initDeepLinks() async {
  final deepLinkService = DeepLinkService();
  await deepLinkService.init();

  deepLinkService.stream.listen((uri) async {
    await _handleDeepLink(uri); // 💥 run async, avoid blocking main thread
  });
}

/// Handle deep link
Future<void> _handleDeepLink(Uri uri) async {
  if (uri.pathSegments.contains('ship')) {
    // Delay 0 to avoid blocking main thread
    await Future.delayed(Duration.zero);
    appRouter.go('/ship');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Init Dependency Injection
  await di.init();

  // 🔹 Init Supabase
  await Supabase.initialize(
    url: 'https://dbgmyreieahiqnwlcxzq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiZ215cmVpZWFoaXFud2xjeHpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4OTMwMjIsImV4cCI6MjA3OTQ2OTAyMn0.NfxVXz85VI1bN0wfpnxIYMIlndaDMev1cg4_1YRlQek',
  );

  // 🔹 Init deep link (Flutter-native)
  await initDeepLinks();

  // 🔹 Init Firebase with options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔹 Init FCM (Firebase Cloud Messaging)
  // Initialize FCM regardless of login status (needed for login/register screens)
  try {
    await FCMService().initialize();
    print('✅ FCM initialized successfully');
  } catch (e) {
    print('⚠️ FCM init error: $e');
  }

  // 🔹 Init Local Notifications
  try {
    await LocalNotificationService().initialize();
    print('✅ Local notifications initialized successfully');
  } catch (e) {
    print('⚠️ Local notification init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
      overlayColor: Colors.grey.withOpacity(0.8),
      overlayWidgetBuilder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
      child: MaterialApp.router(
        title: 'Marine Analytics Platform',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        builder: (context, child) {
          return child!;
        },
        // Add navigator key for FCM navigation
        // Note: This is a workaround since GoRouter doesn't directly support navigatorKey
        // We'll use the router's navigator key instead
      ),
    );
  }
}
