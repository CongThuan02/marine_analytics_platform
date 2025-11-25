import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marine_analytics_platform/global.dart';

/// Service quản lý Firebase Cloud Messaging
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Khởi tạo FCM
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
  }

  /// Setup local notifications
  Future<void> _setupLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
        'Cảnh báo Hạn mức',
        description: 'Thông báo khi vượt hạn mức chất thải',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      
      print('✅ Local notifications initialized');
    } catch (e) {
      print('⚠️ Error initializing local notifications: $e');
      // Không fail initialization nếu local notifications lỗi
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Khi app ở foreground, FCM không tự động hiển thị notification
    // Có thể hiển thị dialog, snackbar, hoặc local notification
    // Tạm thời chỉ log, notification sẽ hiển thị khi app ở background
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification == null) {
        print('⚠️ Notification is null, skipping local notification');
        return;
      }

      // Đơn giản hóa - không dùng local notification, chỉ log
      print('📬 Notification received:');
      print('   Title: ${notification.title}');
      print('   Body: ${notification.body}');
      print('   Data: ${message.data}');
      
      // FCM sẽ tự động hiển thị notification khi app ở background
      // Khi app ở foreground, có thể hiển thị dialog hoặc snackbar thay vì notification
      
    } catch (e) {
      print('❌ Error handling notification: $e');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // Navigate to alerts page
    // You can use navigation service here
  }

  /// Save FCM token to database
  Future<void> _saveFCMToken(String token) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Lưu token vào bảng user_fcm_tokens với upsert
      await supabase.from('user_fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token', // Chỉ định unique constraint
      );

      print('✅ FCM token saved to database');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
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
