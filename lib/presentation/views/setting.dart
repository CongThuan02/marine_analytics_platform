import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/services/local_notification_service.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/global.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info section
          _buildUserSection(context),
          const SizedBox(height: 24),

          // Management section
          _buildSectionTitle('System Management'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.location_on,
            title: 'Manage Areas',
            subtitle: 'Add, edit, delete areas',
            onTap: () => context.pushNamed('/create/area'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.business,
            title: 'Manage Departments',
            subtitle: 'Add, edit, delete departments',
            onTap: () => context.pushNamed('/department'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.delete_outline,
            title: 'Manage Waste Types',
            subtitle: 'Add, edit, delete waste types',
            onTap: () => context.pushNamed('/wasteType'),
          ),
          const SizedBox(height: 24),

          // Monitoring section
          _buildSectionTitle('Monitoring & Alerts'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.notification_important,
            title: 'Limit Alerts',
            subtitle: 'View threshold alerts',
            onTap: () => context.pushNamed('/alerts'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.speed,
            title: 'Manage Limits',
            subtitle: 'Set waste alert thresholds',
            onTap: () => context.pushNamed('/wasteLimit'),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.notifications_active,
            title: 'Manage Reminders',
            subtitle: 'Configure data entry reminders',
            onTap: () => context.pushNamed('/reminder'),
          ),
          const SizedBox(height: 24),

          // Testing section
          if (kDebugMode) ...{
            _buildSectionTitle('Testing & Debug'),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              icon: Icons.bug_report,
              title: 'Test Local Notification',
              subtitle: 'Test notification without FCM/Google',
              onTap: () => _testLocalNotification(context),
            ),
            const SizedBox(height: 8),
            _buildSettingCard(
              context,
              icon: Icons.warning_amber,
              title: 'Test Waste Limit Alert',
              subtitle: 'Test waste limit exceeded notification',
              onTap: () => _testWasteLimitNotification(context),
            ),
            const SizedBox(height: 24),
          },
          // Account section
          _buildSectionTitle('Account'),
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
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreenLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Logged in',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
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
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade700, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign out from current account',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade600,
                      ),
                    ),
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
            Text('Confirm Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _testLocalNotification(BuildContext context) async {
    try {
      print('🔔 Testing local notification...');

      await LocalNotificationService().showNotification(
        title: '✅ Test Success!',
        body: 'Local notification is working! No FCM/Google needed.',
        payload: 'test',
      );

      print('✅ Notification sent');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification sent! Check your notification tray.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testWasteLimitNotification(BuildContext context) async {
    try {
      print('🔔 Testing waste limit notification...');

      await LocalNotificationService().showWasteLimitExceededNotification(
        areaName: 'Test Kitchen',
        wasteTypeName: 'Plastic Waste',
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
            content: Text(
              '⚠️ Waste limit alert sent! Check notification tray.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        context.pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
