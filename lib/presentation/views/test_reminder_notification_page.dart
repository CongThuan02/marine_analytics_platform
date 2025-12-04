import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/services/reminder_notification_service.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';

class TestReminderNotificationPage extends StatefulWidget {
  const TestReminderNotificationPage({super.key});

  @override
  State<TestReminderNotificationPage> createState() =>
      _TestReminderNotificationPageState();
}

class _TestReminderNotificationPageState
    extends State<TestReminderNotificationPage> {
  final _service = ReminderNotificationService();
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)} - $message',
      );
    });
  }

  Future<void> _testImmediateNotification() async {
    _addLog('Testing immediate notification (1 minute from now)...');

    final now = DateTime.now().add(const Duration(minutes: 1));
    final testReminder = Reminder(
      id: 'test-immediate-${DateTime.now().millisecondsSinceEpoch}',
      departmentId: 'test-dept',
      timeOfDay:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      frequency: 'daily',
      message: 'Test notification - Should appear in 1 minute',
      enabled: true,
      createdAt: DateTime.now(),
      departmentName: 'Test Department',
    );

    await _service.scheduleReminder(testReminder);
    _addLog('✅ Scheduled notification for ${testReminder.timeOfDay}');
  }

  Future<void> _testDailyReminder() async {
    _addLog('Testing daily reminder...');

    final testReminder = Reminder(
      id: 'test-daily-${DateTime.now().millisecondsSinceEpoch}',
      departmentId: 'test-dept',
      timeOfDay: '09:00',
      frequency: 'daily',
      message: 'Daily reminder at 9:00 AM',
      enabled: true,
      createdAt: DateTime.now(),
      departmentName: 'Test Department',
    );

    await _service.scheduleReminder(testReminder);
    _addLog('✅ Scheduled daily reminder at 09:00');
  }

  Future<void> _testWeeklyReminder() async {
    _addLog('Testing weekly reminder...');

    final testReminder = Reminder(
      id: 'test-weekly-${DateTime.now().millisecondsSinceEpoch}',
      departmentId: 'test-dept',
      timeOfDay: '14:00',
      frequency: 'weekly',
      message: 'Weekly reminder at 2:00 PM',
      enabled: true,
      createdAt: DateTime.now(),
      departmentName: 'Test Department',
    );

    await _service.scheduleReminder(testReminder);
    _addLog('✅ Scheduled weekly reminder at 14:00');
  }

  Future<void> _testMonthlyReminder() async {
    _addLog('Testing monthly reminder...');

    final testReminder = Reminder(
      id: 'test-monthly-${DateTime.now().millisecondsSinceEpoch}',
      departmentId: 'test-dept',
      timeOfDay: '10:30',
      frequency: 'monthly',
      message: 'Monthly reminder at 10:30 AM',
      enabled: true,
      createdAt: DateTime.now(),
      departmentName: 'Test Department',
    );

    await _service.scheduleReminder(testReminder);
    _addLog('✅ Scheduled monthly reminder at 10:30');
  }

  Future<void> _cancelAllReminders() async {
    _addLog('Cancelling all reminders...');
    await _service.cancelAllReminders();
    _addLog('✅ All reminders cancelled');
  }

  Future<void> _checkPendingNotifications() async {
    _addLog('Checking pending notifications...');
    final pending = await _service.getPendingNotifications();
    _addLog('📋 Found ${pending.length} pending notifications');
    for (final notification in pending) {
      _addLog('  - ID: ${notification.id}, Title: ${notification.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Reminder Notifications')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _testImmediateNotification,
                  icon: const Icon(Icons.alarm),
                  label: const Text('Test Immediate (1 min)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _testDailyReminder,
                  icon: const Icon(Icons.today),
                  label: const Text('Test Daily (9:00 AM)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _testWeeklyReminder,
                  icon: const Icon(Icons.calendar_view_week),
                  label: const Text('Test Weekly (2:00 PM)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _testMonthlyReminder,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Test Monthly (10:30 AM)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _checkPendingNotifications,
                  icon: const Icon(Icons.list),
                  label: const Text('Check Pending'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _cancelAllReminders,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Cancel All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() => _logs.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text('No logs yet. Press a button to test.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
