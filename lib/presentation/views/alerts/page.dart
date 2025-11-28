import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_analytics_platform/core/constants/app_strings.dart';
import 'package:marine_analytics_platform/core/di/injection_container.dart';
import 'package:marine_analytics_platform/core/theme/app_theme.dart';
import 'package:marine_analytics_platform/data/models/alert_model.dart';
import 'package:marine_analytics_platform/presentation/blocs/alert/alert_bloc.dart';
import 'package:marine_analytics_platform/presentation/views/alerts/widgets/alert_card.dart';

import '../../../domain/entities/alert.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => sl<AlertBloc>()..add(const LoadAlerts()), child: const _AlertsView());
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alertsTitle),
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
                    Text(AppStrings.testCreateAlert),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_old',
                child: Row(
                  children: [Icon(Icons.delete_sweep, size: 20), SizedBox(width: 8), Text(AppStrings.deleteOldAlerts)],
                ),
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
                    '${AppStrings.error}: ${state.message}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AlertBloc>().add(LoadAlerts());
                    },
                    child: const Text('Retry'),
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
                    const Text(AppStrings.noAlerts, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('All areas are within limits', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AlertBloc>().add(LoadAlerts());
              },
              child: Column(
                children: [
                  _buildSummarySection(state.alerts),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.alerts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return AlertCard(alert: state.alerts[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummarySection(List<Alert> alerts) {
    final total = alerts.length;
    final critical = alerts.where((a) => a.level == AlertLevel.critical).length;
    final warning = alerts.where((a) => a.level == AlertLevel.warning).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreenLight.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.warning_amber_rounded,
              label: 'Total Alerts',
              value: total.toString(),
              color: AppTheme.primaryGreen,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.error,
              label: 'Critical',
              value: critical.toString(),
              color: Colors.red,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.info,
              label: 'Warning',
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
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
            Text(AppStrings.deleteOldAlerts),
          ],
        ),
        content: const Text('Delete all alerts before today?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement DeleteOldAlerts use case
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
