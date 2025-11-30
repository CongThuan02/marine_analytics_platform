import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/routes/app_router.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_initialized) return;

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'waste_limit_alerts',
      'Waste Limit Alerts',
      description: 'Notifications when waste limit is exceeded',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
    print('✅ Local notifications initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');

    // Navigate to alerts page
    if (response.payload != null &&
        response.payload!.startsWith('waste_limit_exceeded')) {
      print('📍 Navigating to alerts page...');

      // Use push() instead of go() to preserve navigation stack
      // This allows users to go back to previous screen
      try {
        appRouter.push('/alerts');
        print('✅ Navigation successful using push()');
      } catch (e) {
        print('❌ Navigation error: $e');
      }
    }
  }

  /// Check if waste entry exceeds limit and show notification
  Future<void> checkAndNotifyWasteLimit({
    required String areaId,
    required String wasteTypeId,
    required double quantity,
    required String areaName,
    required String wasteTypeName,
  }) async {
    try {
      print('📊 [LIMIT CHECK] Checking waste limit...');
      print('   Area: $areaName ($areaId)');
      print('   Waste Type: $wasteTypeName ($wasteTypeId)');
      print('   New Quantity: $quantity');

      // Get current month's total for this area and waste type
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      final firstDay = firstDayOfMonth.toIso8601String().split('T')[0];
      final lastDay = lastDayOfMonth.toIso8601String().split('T')[0];

      print('   Date range: $firstDay to $lastDay');

      // Query total waste for current month
      final response = await supabase
          .from('waste_entries')
          .select('quantity')
          .eq('area_id', areaId)
          .eq('waste_type_id', wasteTypeId)
          .gte('date', firstDay)
          .lte('date', lastDay);

      print('   Found ${(response as List).length} entries this month');

      double totalQuantity = 0;
      for (final entry in response) {
        final qty = (entry['quantity'] as num).toDouble();
        totalQuantity += qty;
        print('   Entry quantity: $qty');
      }

      print('   Total quantity this month: $totalQuantity');

      // Get waste limit for this area and waste type
      final limitResponse = await supabase
          .from('waste_limits')
          .select('daily_limit')
          .eq('area_id', areaId)
          .eq('waste_type_id', wasteTypeId)
          .maybeSingle();

      if (limitResponse == null) {
        print('ℹ️ [LIMIT CHECK] No limit set for this area and waste type');
        return;
      }

      final limitValue = (limitResponse['daily_limit'] as num).toDouble();
      final period = 'monthly'; // Default to monthly for now

      print('   Limit: $limitValue (daily limit, checking monthly total)');

      // Check if exceeded
      print('   Comparing: $totalQuantity > $limitValue ?');

      if (totalQuantity > limitValue) {
        print('⚠️ [LIMIT CHECK] EXCEEDED! Showing notification...');

        final exceededBy = totalQuantity - limitValue;
        final percentage = ((totalQuantity / limitValue) * 100).toStringAsFixed(
          1,
        );

        await showWasteLimitExceededNotification(
          areaName: areaName,
          wasteTypeName: wasteTypeName,
          totalQuantity: totalQuantity,
          limitValue: limitValue,
          exceededBy: exceededBy,
          percentage: percentage,
          period: period,
        );

        print('✅ [LIMIT CHECK] Notification sent!');
        print(
          '   Total: $totalQuantity, Limit: $limitValue, Exceeded by: $exceededBy',
        );
      } else {
        print('✅ [LIMIT CHECK] Within limit');
        print(
          '   Total: $totalQuantity, Limit: $limitValue, Remaining: ${limitValue - totalQuantity}',
        );
      }
    } catch (e) {
      print('❌ [LIMIT CHECK] Error: $e');
    }
  }

  /// Show waste limit exceeded notification
  Future<void> showWasteLimitExceededNotification({
    required String areaName,
    required String wasteTypeName,
    required double totalQuantity,
    required double limitValue,
    required double exceededBy,
    required String percentage,
    required String period,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'waste_limit_alerts',
      'Waste Limit Alerts',
      channelDescription: 'Notifications when waste limit is exceeded',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFFF5252), // Red color for alert
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = '⚠️ Waste Limit Exceeded!';
    final body =
        'Area: $areaName\n'
        'Waste Type: $wasteTypeName\n'
        'Current Total: ${totalQuantity.toStringAsFixed(1)} kg\n'
        'Daily Limit: ${limitValue.toStringAsFixed(1)} kg\n'
        'Exceeded by: ${exceededBy.toStringAsFixed(1)} kg (${percentage}%)';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: 'waste_limit_exceeded:$areaName:$wasteTypeName',
    );

    print('📬 Local notification shown: $title');
  }

  /// Show a simple notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'waste_limit_alerts',
      'Waste Limit Alerts',
      channelDescription: 'Notifications when waste limit is exceeded',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
