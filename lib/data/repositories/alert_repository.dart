import 'package:marine_analytics_platform/data/models/alert_model.dart';
import 'package:marine_analytics_platform/global.dart';

class AlertRepository {
  /// Lấy tất cả cảnh báo
  Future<List<AlertModel>> fetchAll() async {
    final response = await supabase
        .from('alerts')
        .select('*, areas(name), waste_types(name, unit)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AlertModel.fromJson(json))
        .toList();
  }

  /// Lấy cảnh báo hôm nay
  Future<List<AlertModel>> fetchToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      print('🔍 Fetching alerts from: ${startOfDay.toIso8601String()}');
      
      final response = await supabase
          .from('alerts')
          .select('*, areas(name), waste_types(name, unit)')
          .gte('created_at', startOfDay.toIso8601String())
          .order('created_at', ascending: false);

      print('📦 Response: $response');
      print('📊 Total alerts: ${(response as List).length}');

      final alerts = (response as List)
          .map((json) {
            try {
              return AlertModel.fromJson(json);
            } catch (e) {
              print('❌ Error parsing alert: $e');
              print('   JSON: $json');
              return null;
            }
          })
          .whereType<AlertModel>()
          .toList();
      
      print('✅ Parsed ${alerts.length} alerts');
      return alerts;
    } catch (e, stackTrace) {
      print('❌ Error fetching alerts: $e');
      print('   Stack: $stackTrace');
      rethrow;
    }
  }

  /// Lấy cảnh báo theo khu vực
  Future<List<AlertModel>> fetchByArea(String areaId) async {
    final response = await supabase
        .from('alerts')
        .select('*, areas(name), waste_types(name, unit)')
        .eq('area_id', areaId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AlertModel.fromJson(json))
        .toList();
  }

  /// Kiểm tra và tạo cảnh báo cho hôm nay
  Future<List<AlertModel>> checkAndCreateAlerts() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Gọi function trong database để kiểm tra và tạo cảnh báo
    // Function này cần được tạo trong Supabase
    final response = await supabase.rpc('check_waste_limits_today', params: {
      'check_date': dateStr,
    });

    if (response == null) return [];

    return (response as List)
        .map((json) => AlertModel.fromJson(json))
        .toList();
  }

  /// Xóa cảnh báo
  Future<void> delete(String id) async {
    await supabase.from('alerts').delete().eq('id', id);
  }

  /// Xóa tất cả cảnh báo cũ (trước hôm nay)
  Future<void> deleteOld() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    await supabase
        .from('alerts')
        .delete()
        .lt('created_at', startOfDay.toIso8601String());
  }
}
