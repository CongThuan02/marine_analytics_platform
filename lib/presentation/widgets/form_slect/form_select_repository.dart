import 'package:marine_analytics_platform/global.dart';

class FormSelectRepository {
  Future<List<Map<String, dynamic>>?> getAllItems({
    required String tableName,
    String? filterColumn,
    String? filterValue,
  }) async {
    try {
      var query = supabase.from(tableName).select();

      // Apply filter if provided
      // Include items where filterColumn = filterValue OR filterColumn is null
      if (filterColumn != null &&
          filterValue != null &&
          filterValue != 'select') {
        query = query.or('$filterColumn.eq.$filterValue,$filterColumn.is.null');
      }

      final res = await query;
      return res;
    } catch (e, st) {
      print('Error fetching data: $e');
      print('StackTrace: $st');
      return [];
    }
  }
}
