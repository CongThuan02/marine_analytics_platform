import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine_analytics_platform/core/localization/localization_extension.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/domain/entities/alert.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/alert/alert_bloc.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _getColorForLevel(alert.level);
    final icon = _getIconForLevel(alert.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.areaName ?? 'Khu vực không xác định',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.wasteTypeName ??
                              'Loại chất thải không xác định',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${alert.percent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: alert.percent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.trending_up,
                      label: 'Hôm nay',
                      value:
                          '${_formatQuantity(alert.totalToday)} ${alert.wasteTypeUnit ?? 'kg'}',
                      color: color,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.speed,
                      label: 'Hạn mức',
                      value:
                          '${_formatQuantity(alert.limitValue)} ${alert.wasteTypeUnit ?? 'kg'}',
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),

              // Message
              if (alert.message != null && alert.message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.message!,
                          style: TextStyle(fontSize: 13, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Actions
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(alert.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(context.l10n.close),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getColorForLevel(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return Colors.blue;
    }
  }

  IconData _getIconForLevel(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Icons.error;
      case AlertLevel.warning:
        return Icons.warning_amber_rounded;
      case AlertLevel.info:
        return Icons.info;
    }
  }

  String _formatQuantity(double quantity) {
    final isInt = quantity % 1 == 0;
    return isInt ? quantity.toStringAsFixed(0) : quantity.toStringAsFixed(2);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Xóa cảnh báo'),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xóa cảnh báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                // Delete alert from database
                await supabase.from('alerts').delete().eq('id', alert.id);

                // Reload alerts
                if (context.mounted) {
                  context.read<AlertBloc>().add(LoadAlerts());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đóng cảnh báo thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }
}
