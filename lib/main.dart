import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:marine_analytics_platform/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:uni_links/uni_links.dart';

Future<void> initUniLinks() async {
  try {
    // Khi app đang chạy nền hoặc foreground
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Khi app vừa mở từ QR
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  } on PlatformException {
    print("object");
  }
}

void _handleDeepLink(Uri uri) {
  if (uri.pathSegments.contains('ship')) {
    appRouter.go('/intro');
  }
  // print(uri.data);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dbgmyreieahiqnwlcxzq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiZ215cmVpZWFoaXFud2xjeHpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4OTMwMjIsImV4cCI6MjA3OTQ2OTAyMn0.NfxVXz85VI1bN0wfpnxIYMIlndaDMev1cg4_1YRlQek',
  );
  await initUniLinks();
  await Firebase.initializeApp();
  runApp(MyApp());
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
      duration: Durations.medium4,
      reverseDuration: Durations.medium4,
      overlayColor: Colors.grey.withValues(alpha: 0.8),
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(child: CircularProgressIndicator());
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
