import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/services/fcm_service.dart';
import 'package:marine_analytics_platform/core/services/local_notification_service.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/global.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info section
          _buildUserSection(context),
          const SizedBox(height: 24),

          // Management section
          _buildSectionTitle('Quản lý hệ thống'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.location_on,
            title: 'Quản lý khu vực',
            subtitle: 'Thêm, sửa, xóa khu vực',
            onTap: () => context.pushNamed('/create/area'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.business,
            title: 'Quản lý phòng',
            subtitle: 'Thêm, sửa, xóa phòng',
            onTap: () => context.pushNamed('/department'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.delete_outline,
            title: 'Quản lý loại chất thải',
            subtitle: 'Thêm, sửa, xóa loại chất thải',
            onTap: () => context.pushNamed('/wasteType'),
          ),
          const SizedBox(height: 24),

          // Monitoring section
          _buildSectionTitle('Giám sát & Cảnh báo'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.notification_important,
            title: 'Cảnh báo hạn mức',
            subtitle: 'Xem cảnh báo vượt ngưỡng',
            onTap: () => context.pushNamed('/alerts'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.speed,
            title: 'Quản lý hạn mức',
            subtitle: 'Thiết lập ngưỡng cảnh báo chất thải',
            onTap: () => context.pushNamed('/wasteLimit'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.notifications_active,
            title: 'Quản lý nhắc nhở',
            subtitle: 'Cấu hình nhắc nhở nhập liệu',
            onTap: () => context.pushNamed('/reminder'),
          ),
          const SizedBox(height: 24),

          // Testing section
          if (kDebugMode) ...{
            _buildSectionTitle('Kiểm tra & Debug'),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              icon: Icons.notifications_active,
              title: 'Xem FCM Token',
              subtitle: 'Hiển thị Firebase Cloud Messaging token',
              onTap: () => _showFCMToken(context),
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              context,
              icon: Icons.bug_report,
              title: 'Test thông báo cục bộ',
              subtitle: 'Kiểm tra thông báo không cần FCM/Google',
              onTap: () => _testLocalNotification(context),
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              context,
              icon: Icons.warning_amber,
              title: 'Test cảnh báo hạn mức',
              subtitle: 'Kiểm tra thông báo vượt hạn mức',
              onTap: () => _testWasteLimitNotification(context),
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              context,
              icon: Icons.alarm,
              title: 'Test nhắc nhở tự động',
              subtitle: 'Kiểm tra thông báo nhắc nhở theo lịch',
              onTap: () => context.pushNamed('/test-reminder-notification'),
            ),
            const SizedBox(height: 24),
          },
          // Account section
          _buildSectionTitle('Tài khoản'),
          const SizedBox(height: 12),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen.withOpacity(0.1), AppTheme.primaryGreenLight.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.email ?? 'User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Đã đăng nhập', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.logout, color: Colors.red.shade700, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đăng xuất',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text('Thoát khỏi tài khoản hiện tại', style: TextStyle(fontSize: 13, color: Colors.red.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.red.shade400),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Xác nhận đăng xuất'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFCMToken(BuildContext context) async {
    final fcmService = FCMService();
    final token = fcmService.fcmToken;

    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ FCM Token chưa sẵn sàng. Vui lòng đợi vài giây...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('FCM Token'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase Cloud Messaging token:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  token,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dùng token này để test gửi notification từ Firebase Console',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Đóng')),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Đã sao chép FCM Token vào clipboard!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Sao chép'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _testLocalNotification(BuildContext context) async {
    try {
      print('🔔 Testing local notification...');

      await LocalNotificationService().showNotification(
        title: '✅ Test thành công!',
        body: 'Thông báo cục bộ đang hoạt động! Không cần FCM/Google.',
        payload: 'test',
      );

      print('✅ Notification sent');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã gửi thông báo! Kiểm tra khay thông báo.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Lỗi: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _testWasteLimitNotification(BuildContext context) async {
    try {
      print('🔔 Testing waste limit notification...');

      await LocalNotificationService().showWasteLimitExceededNotification(
        areaName: 'Bếp Test',
        wasteTypeName: 'Rác nhựa',
        totalQuantity: 125.5,
        limitValue: 100.0,
        exceededBy: 25.5,
        percentage: '125.5',
        period: 'monthly',
      );

      print('✅ Waste limit notification sent');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Đã gửi cảnh báo hạn mức! Kiểm tra khay thông báo.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Lỗi: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sign out from Supabase
      await supabase.auth.signOut();

      // Close loading dialog
      if (context.mounted) {
        context.pop();
      }

      // Navigate to login
      if (context.mounted) {
        context.go('/login');
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng xuất thành công'), backgroundColor: AppTheme.success));
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        context.pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đăng xuất: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
