import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/global.dart';

class FormSelectRepository {
  Future<List<Map<String, dynamic>>?> getAllItems({required String tableName}) async {
    try {
      final res = await supabase.from(tableName).select();
      return res;
    } catch (e, st) {
      print('Error fetching areas: $e');
      print('StackTrace: $st');
      return [];
    }
  }
}
