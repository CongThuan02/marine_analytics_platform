import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/core/services/local_notification_service.dart';

class TestLocalNotificationPage extends StatelessWidget {
  const TestLocalNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test thông báo cục bộ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test Local Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap buttons below to test different notification scenarios',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Test 1: Simple notification
          ElevatedButton.icon(
            onPressed: () => _testSimpleNotification(context),
            icon: const Icon(Icons.notifications),
            label: const Text('Test thông báo đơn giản'),
          ),
          const SizedBox(height: 12),

          // Test 2: Waste limit notification
          ElevatedButton.icon(
            onPressed: () => _testWasteLimitNotification(context),
            icon: const Icon(Icons.warning),
            label: const Text('Test thông báo hạn mức'),
          ),
          const SizedBox(height: 12),

          // Test 3: Check permissions
          ElevatedButton.icon(
            onPressed: () => _checkPermissions(context),
            icon: const Icon(Icons.info),
            label: const Text('Kiểm tra trạng thái thông báo'),
          ),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Debug Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          _buildDebugInfo(),
        ],
      ),
    );
  }

  Future<void> _testSimpleNotification(BuildContext context) async {
    try {
      await LocalNotificationService().showNotification(
        title: '✅ Test Notification',
        body:
            'This is a test notification. If you see this, notifications are working!',
        payload: 'test',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification sent! Check your notification tray.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testWasteLimitNotification(BuildContext context) async {
    try {
      await LocalNotificationService().showWasteLimitExceededNotification(
        areaName: 'Test Area',
        wasteTypeName: 'Test Waste',
        totalQuantity: 125.5,
        limitValue: 100.0,
        exceededBy: 25.5,
        percentage: '125.5',
        period: 'monthly',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã gửi thông báo hạn mức!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _checkPermissions(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trạng thái thông báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Để kiểm tra quyền thông báo:'),
            const SizedBox(height: 12),
            const Text(
              'Android:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('Cài đặt → Ứng dụng → Ứng dụng của bạn → Thông báo'),
            const SizedBox(height: 12),
            const Text('iOS:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Cài đặt → Ứng dụng của bạn → Thông báo'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Nếu thông báo không hiển thị:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('1. Kiểm tra quyền ở trên'),
            const Text('2. Khởi động lại ứng dụng'),
            const Text('3. Thử "Test thông báo đơn giản"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Service', 'LocalNotificationService'),
            _buildInfoRow('Channel ID', 'waste_limit_alerts'),
            _buildInfoRow('Channel Name', 'Waste Limit Alerts'),
            _buildInfoRow('Importance', 'High'),
            _buildInfoRow('Sound', 'Enabled'),
            _buildInfoRow('Vibration', 'Enabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
