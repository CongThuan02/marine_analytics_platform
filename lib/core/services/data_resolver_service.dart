import 'package:marine_analytics_platform/global.dart';

class DataResolverService {
  /// Resolve department name to ID, create if not exists
  Future<String> resolveDepartmentId(String departmentName) async {
    if (departmentName.isEmpty) {
      throw Exception('Tên phòng ban không được để trống');
    }

    try {
      // Tìm department theo tên
      final response = await supabase
          .from('departments')
          .select('id')
          .eq('name', departmentName)
          .maybeSingle();

      if (response != null) {
        return response['id'] as String;
      }

      // Nếu không tìm thấy, tạo mới
      final createResponse = await supabase
          .from('departments')
          .insert({'name': departmentName})
          .select('id')
          .single();

      return createResponse['id'] as String;
    } catch (e) {
      throw Exception('Lỗi khi xử lý phòng ban "$departmentName": $e');
    }
  }

  /// Resolve area name to ID, create if not exists
  Future<String> resolveAreaId(String areaName) async {
    if (areaName.isEmpty) {
      throw Exception('Tên khu vực không được để trống');
    }

    try {
      // Tìm area theo tên
      final response = await supabase
          .from('areas')
          .select('id')
          .eq('name', areaName)
          .maybeSingle();

      if (response != null) {
        return response['id'] as String;
      }

      // Nếu không tìm thấy, tạo mới
      final createResponse = await supabase
          .from('areas')
          .insert({'name': areaName})
          .select('id')
          .single();

      return createResponse['id'] as String;
    } catch (e) {
      throw Exception('Lỗi khi xử lý khu vực "$areaName": $e');
    }
  }

  /// Resolve waste type name to ID, create if not exists
  Future<String> resolveWasteTypeId(String wasteTypeName, String unit) async {
    if (wasteTypeName.isEmpty) {
      throw Exception('Tên loại chất thải không được để trống');
    }

    try {
      // Tìm waste type theo tên
      final response = await supabase
          .from('waste_types')
          .select('id')
          .eq('name', wasteTypeName)
          .maybeSingle();

      if (response != null) {
        return response['id'] as String;
      }

      // Nếu không tìm thấy, tạo mới
      final createResponse = await supabase
          .from('waste_types')
          .insert({
            'name': wasteTypeName,
            'unit': unit.isNotEmpty ? unit : 'kg',
          })
          .select('id')
          .single();

      return createResponse['id'] as String;
    } catch (e) {
      throw Exception('Lỗi khi xử lý loại chất thải "$wasteTypeName": $e');
    }
  }

  /// Resolve all IDs for a waste entry
  Future<Map<String, String>> resolveWasteEntryIds({
    required String wasteTypeName,
    required String unit,
    String? departmentName,
    String? areaName,
  }) async {
    final results = <String, String>{};

    // Resolve waste type (bắt buộc)
    results['wasteTypeId'] = await resolveWasteTypeId(wasteTypeName, unit);

    // Resolve department (tùy chọn)
    if (departmentName != null && departmentName.isNotEmpty) {
      results['departmentId'] = await resolveDepartmentId(departmentName);
    } else {
      results['departmentId'] = '';
    }

    // Resolve area (tùy chọn)
    if (areaName != null && areaName.isNotEmpty) {
      results['areaId'] = await resolveAreaId(areaName);
    } else {
      results['areaId'] = '';
    }

    return results;
  }

  /// Get current user ID
  String getCurrentUserId() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Bạn chưa đăng nhập');
    }
    return userId;
  }
}
