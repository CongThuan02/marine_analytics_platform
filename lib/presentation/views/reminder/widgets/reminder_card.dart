import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/domain/entities/reminder.dart';
import 'package:marine_analytics_platform/presentation/blocs/reminder/reminder_bloc.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: reminder.enabled ? AppTheme.primaryGreenLight.withOpacity(0.2) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: reminder.enabled ? AppTheme.primaryGreen : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.departmentName ?? 'Bộ phận không được chỉ định',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.frequency == 'daily' ? 'Hàng ngày' : 'Hàng tuần',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.enabled,
                  onChanged: (value) {
                    context.read<ReminderBloc>().add(ToggleReminderEvent(reminder.id, value));
                  },
                  activeThumbColor: AppTheme.primaryGreen,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text('Thời gian: ${_formatTime(reminder.timeOfDay)}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            if (reminder.message != null && reminder.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.message, size: 20, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reminder.message!, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (e) {
      return time;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa nhắc nhở này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<ReminderBloc>().add(DeleteReminderEvent(reminder.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa nhắc nhở')));
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
