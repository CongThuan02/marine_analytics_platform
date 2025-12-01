import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/global.dart';

/// Test page to create alerts manually
class TestAlertsPage extends StatefulWidget {
  const TestAlertsPage({super.key});

  @override
  State<TestAlertsPage> createState() => _TestAlertsPageState();
}

class _TestAlertsPageState extends State<TestAlertsPage> {
  bool _loading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test tạo cảnh báo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Instructions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Ensure waste_limits exist in database\n'
                    '2. Ensure waste_entries exist for today\n'
                    '3. Press button below to check and create alerts',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _checkAndCreateAlerts,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_loading ? 'Checking...' : 'Check & Create Alerts'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _createTestAlert,
              icon: const Icon(Icons.add_alert),
              label: const Text('Tạo cảnh báo test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _deleteAllAlerts,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Xóa tất cả cảnh báo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.contains('Error')
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _message.contains('Error')
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('Error')
                        ? Colors.red.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndCreateAlerts() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Get all waste_limits
      final limitsResponse = await supabase
          .from('waste_limits')
          .select('*, areas(name), waste_types(name, unit)');

      final limits = limitsResponse as List;

      if (limits.isEmpty) {
        setState(() {
          _message = 'No limits set. Please create limits first.';
          _loading = false;
        });
        return;
      }

      int alertsCreated = 0;

      // Check each limit
      for (final limit in limits) {
        final areaId = limit['area_id'];
        final wasteTypeId = limit['waste_type_id'];
        final dailyLimit = (limit['daily_limit'] as num).toDouble();

        // Calculate total waste entries for today
        final entriesResponse = await supabase
            .from('waste_entries')
            .select('quantity')
            .eq('area_id', areaId)
            .eq('waste_type_id', wasteTypeId)
            .eq('date', dateStr);

        final entries = entriesResponse as List;
        final total = entries.fold<double>(
          0,
          (sum, entry) => sum + (entry['quantity'] as num).toDouble(),
        );

        final percent = (total / dailyLimit) * 100;

        // If >= 80%, create alert
        if (percent >= 80) {
          final areaName = limit['areas']['name'];
          final wasteTypeName = limit['waste_types']['name'];

          await supabase.from('alerts').insert({
            'area_id': areaId,
            'waste_type_id': wasteTypeId,
            'total_today': total,
            'limit_value': dailyLimit,
            'percent': percent,
            'message': percent >= 100
                ? '🔴 LIMIT EXCEEDED: $wasteTypeName at $areaName has exceeded ${percent.toStringAsFixed(0)}%'
                : '⚠️ WARNING: $wasteTypeName at $areaName has reached ${percent.toStringAsFixed(0)}% of limit',
          });

          alertsCreated++;
        }
      }

      setState(() {
        _message = alertsCreated > 0
            ? 'Created $alertsCreated new alerts!'
            : 'No areas exceeded threshold 80%.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Lỗi: $e';
        _loading = false;
      });
    }
  }

  Future<void> _createTestAlert() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      // Get first area and waste_type
      final areasResponse = await supabase.from('areas').select().limit(1);
      final wasteTypesResponse = await supabase
          .from('waste_types')
          .select()
          .limit(1);

      if ((areasResponse as List).isEmpty ||
          (wasteTypesResponse as List).isEmpty) {
        setState(() {
          _message = 'Need at least 1 area and 1 waste type';
          _loading = false;
        });
        return;
      }

      final area = areasResponse[0];
      final wasteType = wasteTypesResponse[0];

      // Create test alert
      await supabase.from('alerts').insert({
        'area_id': area['id'],
        'waste_type_id': wasteType['id'],
        'total_today': 150.0,
        'limit_value': 100.0,
        'percent': 150.0,
        'message':
            '🔴 TEST: ${wasteType['name']} at ${area['name']} exceeded 150%',
      });

      setState(() {
        _message = 'Đã tạo cảnh báo test thành công!';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Lỗi: $e';
        _loading = false;
      });
    }
  }

  Future<void> _deleteAllAlerts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả cảnh báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      await supabase
          .from('alerts')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');

      setState(() {
        _message = 'Đã xóa tất cả cảnh báo!';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _loading = false;
      });
    }
  }
}
