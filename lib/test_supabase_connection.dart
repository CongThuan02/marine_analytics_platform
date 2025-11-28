import 'package:flutter/material.dart';
import 'package:marine_analytics_platform/global.dart';

/// Test page for Supabase connection
class TestSupabaseConnectionPage extends StatefulWidget {
  const TestSupabaseConnectionPage({super.key});

  @override
  State<TestSupabaseConnectionPage> createState() =>
      _TestSupabaseConnectionPageState();
}

class _TestSupabaseConnectionPageState
    extends State<TestSupabaseConnectionPage> {
  String _result = 'Not tested yet';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing...';
    });

    try {
      // Test 1: Check auth
      final user = supabase.auth.currentUser;
      print('👤 Current user: ${user?.id}');
      print('   Email: ${user?.email}');

      // Test 2: Query areas
      final areasResponse = await supabase.from('areas').select().limit(5);
      print('🏢 Areas: ${areasResponse.length} records');

      // Test 3: Query waste_types
      final wasteTypesResponse = await supabase
          .from('waste_types')
          .select()
          .limit(5);
      print('🗑️ Waste types: ${wasteTypesResponse.length} records');

      // Test 4: Query waste_limits
      final limitsResponse = await supabase
          .from('waste_limits')
          .select()
          .limit(5);
      print('⚠️ Waste limits: ${limitsResponse.length} records');

      // Test 5: Query alerts
      final alertsResponse = await supabase.from('alerts').select().limit(5);
      print('🚨 Alerts: ${alertsResponse.length} records');

      // Test 6: Query alerts with join
      final alertsJoinResponse = await supabase
          .from('alerts')
          .select('*, areas(name), waste_types(name, unit)')
          .limit(5);
      print('🔗 Alerts with join: ${alertsJoinResponse.length} records');
      print('   Data: $alertsJoinResponse');

      setState(() {
        _result =
            '''
✅ Connection successful!

User: ${user?.email ?? 'Not logged in'}
Areas: ${areasResponse.length}
Waste Types: ${wasteTypesResponse.length}
Waste Limits: ${limitsResponse.length}
Alerts: ${alertsResponse.length}
Alerts (join): ${alertsJoinResponse.length}

See details in console logs.
        ''';
      });
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('   Stack: $stackTrace');
      setState(() {
        _result = '❌ Error:\n$e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Supabase Connection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Connection'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
