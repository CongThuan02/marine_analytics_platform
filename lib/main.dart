import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

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
      final uriString = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
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
      final uriString = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (uriString != lastLink && uriString != "/") {
        final uri = Uri.parse(uriString);
        lastLink = uriString;
        _linkStream.add(uri);
      }
    } catch (_) {}
  }
}

/// Khởi tạo deep link và lắng nghe
Future<void> initDeepLinks() async {
  final deepLinkService = DeepLinkService();
  await deepLinkService.init();

  deepLinkService.stream.listen((uri) async {
    await _handleDeepLink(uri); // 💥 chạy async, tránh block main thread
  });
}

/// Xử lý deep link
Future<void> _handleDeepLink(Uri uri) async {
  if (uri.pathSegments.contains('ship')) {
    // Delay 0 để không block main thread
    await Future.delayed(Duration.zero);
    appRouter.go('/intro');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Init Supabase
  await Supabase.initialize(
    url: 'https://dbgmyreieahiqnwlcxzq.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiZ215cmVpZWFoaXFud2xjeHpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4OTMwMjIsImV4cCI6MjA3OTQ2OTAyMn0.NfxVXz85VI1bN0wfpnxIYMIlndaDMev1cg4_1YRlQek',
  );

  // 🔹 Init deep link (Flutter-native)
  await initDeepLinks();

  // 🔹 Init Firebase
  await Firebase.initializeApp();

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
        title: 'Flutter Demo',
        routerConfig: appRouter,
        builder: (context, child) {
          return child!;
        },
      ),
    );
  }
}
