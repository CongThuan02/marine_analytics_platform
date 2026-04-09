import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/routes/app_router.dart';

/// Service to manage Firebase Cloud Messaging
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize FCM
  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM: User granted permission');
    } else {
      print('❌ FCM: User declined permission');
      return;
    }

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('📱 FCM Token: $_fcmToken');

    // Save token to database
    if (_fcmToken != null) {
      await _saveFCMToken(_fcmToken!);
    }

    // Setup local notifications
    await _setupLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _saveFCMToken(newToken);
    });

    _isInitialized = true;
  }

  /// Wait for FCM token to be ready (with timeout)
  /// Returns token if available, null if timeout or error
  Future<String?> waitForToken({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // If token already available, return immediately
    if (_fcmToken != null) {
      print('✅ FCM token already available');
      return _fcmToken;
    }

    print('⏳ Waiting for FCM token...');

    try {
      // Try to get token with timeout
      final token = await _messaging.getToken().timeout(
        timeout,
        onTimeout: () {
          print('⏱️ FCM token timeout after ${timeout.inSeconds}s');
          return null;
        },
      );

      if (token != null) {
        _fcmToken = token;
        print('✅ FCM token received: ${token.substring(0, 20)}...');

        // Save to database if user is logged in
        final userId = supabase.auth.currentUser?.id;
        if (userId != null) {
          await _saveFCMToken(token);
        }
      } else {
        print('❌ FCM token is null - check permissions and APNs config');
      }

      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Check if notification permission is granted
  Future<bool> hasPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    print(granted ? '✅ Permission granted' : '❌ Permission denied');
    return granted;
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('Notification tapped: ${details.payload}');
        },
      );

      // Create notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        'alerts_channel',
        'Limit Alerts',
        description: 'Notifications when waste limit is exceeded',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      print('✅ Local notifications initialized');
    } catch (e) {
      print('⚠️ Error initializing local notifications: $e');
      // Don't fail initialization if local notifications error
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // When app is in foreground, FCM doesn't automatically show notification
    // Can show dialog, snackbar, or local notification
    // For now just log, notification will show when app is in background
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');

    // Navigate to alerts page using push instead of go
    // Navigate to alerts page using push instead of go
    // push() preserves the navigation stack and allows back navigation
    // go() replaces the entire stack
    appRouter.push('/alerts');
    print('✅ Navigated to alerts page using push()');
  }

  /// Save FCM token to database
  Future<void> _saveFCMToken(String token) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        print('ℹ️ User not logged in, FCM token not saved to database');
        return;
      }

      // Save token to user_fcm_tokens table with upsert
      await supabase.from('user_fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token', // Specify unique constraint
      );

      print('✅ FCM token saved to database');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Save FCM token after login
  Future<void> saveFCMTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _saveFCMToken(_fcmToken!);
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('✅ Unsubscribed from topic: $topic');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Background message: ${message.notification?.title}');
}
