import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service to manage reminder notifications
class ReminderNotificationService {
  static final ReminderNotificationService _instance =
      ReminderNotificationService._internal();
  factory ReminderNotificationService() => _instance;
  ReminderNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Initialize notifications
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
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Scheduled reminder notifications',
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
    print('✅ ReminderNotificationService initialized');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('🔔 Reminder notification tapped: ${response.payload}');
    // TODO: Navigate to reminder page
  }

  /// Schedule a reminder notification
  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_isInitialized) await initialize();
    if (!reminder.enabled) return;

    try {
      // Parse time (format: "HH:mm")
      final timeParts = reminder.timeOfDay.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Calculate next notification time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Generate unique notification ID from reminder ID
      final notificationId = _generateNotificationId(reminder.id);

      // Schedule based on frequency
      switch (reminder.frequency.toLowerCase()) {
        case 'daily':
          await _scheduleDailyReminder(notificationId, reminder, scheduledDate);
          break;
        case 'weekly':
          await _scheduleWeeklyReminder(
            notificationId,
            reminder,
            scheduledDate,
          );
          break;
        case 'monthly':
          await _scheduleMonthlyReminder(
            notificationId,
            reminder,
            scheduledDate,
          );
          break;
        default:
          print('⚠️ Unknown frequency: ${reminder.frequency}');
      }

      print(
        '✅ Scheduled ${reminder.frequency} reminder at ${reminder.timeOfDay}',
      );
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
    }
  }

  /// Schedule daily reminder
  Future<void> _scheduleDailyReminder(
    int id,
    Reminder reminder,
    tz.TZDateTime scheduledDate,
  ) async {
    await _notifications.zonedSchedule(
      id,
      'Nhắc nhở: ${reminder.departmentName ?? 'Phòng ban'}',
      reminder.message ?? 'Đã đến giờ nhắc nhở',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Scheduled reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: reminder.id,
    );
  }

  /// Schedule weekly reminder
  Future<void> _scheduleWeeklyReminder(
    int id,
    Reminder reminder,
    tz.TZDateTime scheduledDate,
  ) async {
    await _notifications.zonedSchedule(
      id,
      'Nhắc nhở: ${reminder.departmentName ?? 'Phòng ban'}',
      reminder.message ?? 'Đã đến giờ nhắc nhở',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Scheduled reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: reminder.id,
    );
  }

  /// Schedule monthly reminder
  Future<void> _scheduleMonthlyReminder(
    int id,
    Reminder reminder,
    tz.TZDateTime scheduledDate,
  ) async {
    await _notifications.zonedSchedule(
      id,
      'Nhắc nhở: ${reminder.departmentName ?? 'Phòng ban'}',
      reminder.message ?? 'Đã đến giờ nhắc nhở',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Scheduled reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: reminder.id,
    );
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(String reminderId) async {
    if (!_isInitialized) await initialize();

    try {
      final notificationId = _generateNotificationId(reminderId);
      await _notifications.cancel(notificationId);
      print('✅ Cancelled reminder notification: $reminderId');
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
    }
  }

  /// Reschedule all active reminders
  /// Call this on app start to restore scheduled notifications
  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    if (!_isInitialized) await initialize();

    print('🔄 Rescheduling ${reminders.length} reminders...');

    // Cancel all existing notifications first
    await _notifications.cancelAll();

    // Schedule each active reminder
    for (final reminder in reminders) {
      if (reminder.enabled) {
        await scheduleReminder(reminder);
      }
    }

    print('✅ Rescheduled all active reminders');
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) await initialize();

    await _notifications.cancelAll();
    print('✅ Cancelled all reminder notifications');
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) await initialize();

    return await _notifications.pendingNotificationRequests();
  }

  /// Generate consistent notification ID from reminder ID
  int _generateNotificationId(String reminderId) {
    // Use hashCode to generate consistent integer ID
    // Add offset to avoid conflicts with other notification types
    return 10000 + reminderId.hashCode.abs() % 10000;
  }
}
