import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/presentation/blocs/alert/alert_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/alerts/widgets/alert_card.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AlertBloc()..add(LoadAlerts()), child: const _AlertsView());
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh báo Hạn mức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AlertBloc>().add(LoadAlerts());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_old') {
                _showDeleteOldDialog(context);
              } else if (value == 'test') {
                context.pushNamed('/alerts/test');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Test tạo cảnh báo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_old',
                child: Row(children: [Icon(Icons.delete_sweep, size: 20), SizedBox(width: 8), Text('Xóa cảnh báo cũ')]),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AlertBloc, AlertState>(
        builder: (context, state) {
          if (state is AlertLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AlertError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AlertBloc>().add(LoadTodayAlerts());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is AlertLoaded) {
            if (state.alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: AppTheme.success),
                    const SizedBox(height: 16),
                    const Text('Không có cảnh báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Tất cả khu vực đều trong hạn mức', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }

            // Group alerts by level
            final criticalAlerts = state.alerts.where((a) => a.percent >= 100).toList();
            final warningAlerts = state.alerts.where((a) => a.percent >= 80 && a.percent < 100).toList();
            final infoAlerts = state.alerts.where((a) => a.percent < 80).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AlertBloc>().add(LoadTodayAlerts());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary card
                  _buildSummaryCard(context, state.alerts.length, criticalAlerts.length, warningAlerts.length),
                  const SizedBox(height: 24),

                  // Critical alerts
                  if (criticalAlerts.isNotEmpty) ...[
                    _buildSectionTitle('Vượt hạn mức (${criticalAlerts.length})'),
                    const SizedBox(height: 12),
                    ...criticalAlerts.map((alert) => AlertCard(alert: alert)),
                    const SizedBox(height: 24),
                  ],

                  // Warning alerts
                  if (warningAlerts.isNotEmpty) ...[
                    _buildSectionTitle('Gần vượt hạn mức (${warningAlerts.length})'),
                    const SizedBox(height: 12),
                    ...warningAlerts.map((alert) => AlertCard(alert: alert)),
                    const SizedBox(height: 24),
                  ],

                  // Info alerts
                  if (infoAlerts.isNotEmpty) ...[
                    _buildSectionTitle('Thông tin (${infoAlerts.length})'),
                    const SizedBox(height: 12),
                    ...infoAlerts.map((alert) => AlertCard(alert: alert)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int total, int critical, int warning) {
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
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.warning_amber_rounded,
              label: 'Tổng cảnh báo',
              value: total.toString(),
              color: AppTheme.primaryGreen,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.error,
              label: 'Vượt mức',
              value: critical.toString(),
              color: Colors.red,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.info,
              label: 'Cảnh báo',
              value: warning.toString(),
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
    );
  }

  void _showDeleteOldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.orange),
            SizedBox(width: 12),
            Text('Xóa cảnh báo cũ'),
          ],
        ),
        content: const Text('Bạn có muốn xóa tất cả cảnh báo trước hôm nay?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              context.read<AlertBloc>().add(DeleteOldAlerts());
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa cảnh báo cũ')));
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
