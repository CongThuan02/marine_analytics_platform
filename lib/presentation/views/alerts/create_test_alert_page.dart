import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/global.dart';

/// Test page to quickly create alerts
class CreateTestAlertPage extends StatefulWidget {
  const CreateTestAlertPage({super.key});

  @override
  State<CreateTestAlertPage> createState() => _CreateTestAlertPageState();
}

class _CreateTestAlertPageState extends State<CreateTestAlertPage> {
  bool _isLoading = false;
  String? _message;
  List<Map<String, dynamic>> _areas = [];
  List<Map<String, dynamic>> _wasteTypes = [];
  String? _selectedAreaId;
  String? _selectedWasteTypeId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final areas = await supabase.from('areas').select('id, name');
      final wasteTypes = await supabase
          .from('waste_types')
          .select('id, name, unit');

      setState(() {
        _areas = List<Map<String, dynamic>>.from(areas);
        _wasteTypes = List<Map<String, dynamic>>.from(wasteTypes);
        if (_areas.isNotEmpty) _selectedAreaId = _areas.first['id'];
        if (_wasteTypes.isNotEmpty) {
          _selectedWasteTypeId = _wasteTypes.first['id'];
        }
      });
    } catch (e) {
      setState(() => _message = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestAlert() async {
    if (_selectedAreaId == null || _selectedWasteTypeId == null) {
      setState(() => _message = 'Please select area and waste type');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Create alert directly
      await supabase.from('alerts').insert({
        'area_id': _selectedAreaId,
        'waste_type_id': _selectedWasteTypeId,
        'total_today': 85.0,
        'limit_value': 100.0,
        'percent': 85.0,
        'message': '⚠️ TEST ALERT: Already reached 85% of limit',
      });

      setState(() => _message = '✅ Test alert created successfully!');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestData() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Create test area
      final areaResult = await supabase
          .from('areas')
          .insert({'name': 'Test Area ${DateTime.now().millisecond}'})
          .select()
          .single();

      // Create test waste type
      final wasteTypeResult = await supabase
          .from('waste_types')
          .insert({
            'name': 'Test Waste ${DateTime.now().millisecond}',
            'unit': 'kg',
          })
          .select()
          .single();

      // Create limit
      await supabase.from('waste_limits').insert({
        'area_id': areaResult['id'],
        'waste_type_id': wasteTypeResult['id'],
        'daily_limit': 100.0,
      });

      setState(() => _message = '✅ Test data created successfully!');
      await _loadData();
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAllAlerts() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await supabase
          .from('alerts')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
      setState(() => _message = '✅ Deleted all alerts!');
    } catch (e) {
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Create Alert')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Test Alert',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (_areas.isEmpty || _wasteTypes.isEmpty)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              '⚠️ No data yet',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Need to create area and waste type first',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _createTestData,
                              icon: const Icon(Icons.add),
                              label: const Text('Create Test Data'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAreaId,
                      decoration: const InputDecoration(
                        labelText: 'Area',
                        border: OutlineInputBorder(),
                      ),
                      items: _areas.map((area) {
                        return DropdownMenuItem<String>(
                          value: area['id'] as String,
                          child: Text(area['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedAreaId = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWasteTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Waste Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _wasteTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['id'] as String,
                          child: Text('${type['name']} (${type['unit']})'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedWasteTypeId = value),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _createTestAlert,
                      icon: const Icon(Icons.warning),
                      label: const Text('Create Test Alert (85%)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: _deleteAllAlerts,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Delete All Alerts'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  if (_message != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      color: _message!.startsWith('✅')
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _message!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ℹ️ Instructions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. If no data yet, click "Create Test Data"',
                          ),
                          const Text('2. Select area and waste type'),
                          const Text(
                            '3. Click "Create Test Alert" to create alert',
                          ),
                          const Text(
                            '4. Go back to Alerts page to see results',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
