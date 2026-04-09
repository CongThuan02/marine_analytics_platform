import 'package:marine_analytics_platform/core/utils/value_sanitizer.dart';
import 'package:marine_analytics_platform/global.dart';

class DataResolverService {
  /// Resolve department name to ID, create if not exists
  /// Returns empty string if departmentName is empty (optional field)
  Future<String> resolveDepartmentId(String departmentName) async {
    // Sanitize input first
    final sanitizedName = ValueSanitizer.sanitizeString(departmentName);

    // Department is optional - return empty string if not provided
    if (sanitizedName.isEmpty) {
      print(
        'DEBUG: Department name is empty after sanitization, returning empty string',
      );
      return '';
    }

    try {
      print(
        'DEBUG: Resolving department: "$sanitizedName" (original: "$departmentName")',
      );

      // Tìm department theo tên
      final response = await supabase
          .from('departments')
          .select('id')
          .eq('name', sanitizedName)
          .maybeSingle();

      print('DEBUG: Department search response: $response');
      print('DEBUG: Response type: ${response.runtimeType}');

      if (response != null &&
          response is Map<String, dynamic> &&
          response['id'] != null) {
        final idValue = response['id'];
        print('DEBUG: ID value: $idValue, type: ${idValue.runtimeType}');

        // Ensure we have a valid UUID string
        if (idValue is String &&
            idValue.isNotEmpty &&
            !idValue.contains('select')) {
          print('DEBUG: Found existing department ID: $idValue');
          return idValue;
        } else {
          print('DEBUG: Invalid ID format: $idValue');
          throw Exception('ID không hợp lệ từ database: $idValue');
        }
      }

      // Nếu không tìm thấy, tạo mới
      print('DEBUG: Creating new department: "$sanitizedName"');
      final createResponse = await supabase
          .from('departments')
          .insert({'name': sanitizedName})
          .select('id')
          .single();

      print('DEBUG: Department create response: $createResponse');
      print('DEBUG: Create response type: ${createResponse.runtimeType}');

      if (createResponse is Map<String, dynamic> &&
          createResponse['id'] != null) {
        final idValue = createResponse['id'];
        print(
          'DEBUG: Created ID value: $idValue, type: ${idValue.runtimeType}',
        );

        // Ensure we have a valid UUID string
        if (idValue is String &&
            idValue.isNotEmpty &&
            !idValue.contains('select')) {
          print('DEBUG: Created new department ID: $idValue');
          return idValue;
        } else {
          print('DEBUG: Invalid created ID format: $idValue');
          throw Exception('ID được tạo không hợp lệ: $idValue');
        }
      } else {
        throw Exception('Không thể tạo phòng ban mới - response không hợp lệ');
      }
    } catch (e) {
      print('DEBUG: Error resolving department "$departmentName": $e');
      throw Exception('Lỗi khi xử lý phòng ban "$departmentName": $e');
    }
  }

  /// Resolve area name to ID, create if not exists
  /// Returns empty string if areaName is empty (optional field)
  Future<String> resolveAreaId(String areaName) async {
    // Sanitize input first
    final sanitizedName = ValueSanitizer.sanitizeString(areaName);

    // Area is optional - return empty string if not provided
    if (sanitizedName.isEmpty) {
      print(
        'DEBUG: Area name is empty after sanitization, returning empty string',
      );
      return '';
    }

    try {
      print('DEBUG: Resolving area: "$sanitizedName" (original: "$areaName")');

      // Tìm area theo tên
      final response = await supabase
          .from('areas')
          .select('id')
          .eq('name', sanitizedName)
          .maybeSingle();

      print('DEBUG: Area search response: $response');
      print('DEBUG: Response type: ${response.runtimeType}');

      if (response != null &&
          response is Map<String, dynamic> &&
          response['id'] != null) {
        final idValue = response['id'];
        print('DEBUG: ID value: $idValue, type: ${idValue.runtimeType}');

        // Ensure we have a valid UUID string
        if (idValue is String &&
            idValue.isNotEmpty &&
            !idValue.contains('select')) {
          print('DEBUG: Found existing area ID: $idValue');
          return idValue;
        } else {
          print('DEBUG: Invalid ID format: $idValue');
          throw Exception('ID không hợp lệ từ database: $idValue');
        }
      }

      // Nếu không tìm thấy, tạo mới
      print('DEBUG: Creating new area: "$sanitizedName"');
      final createResponse = await supabase
          .from('areas')
          .insert({'name': sanitizedName})
          .select('id')
          .single();

      print('DEBUG: Area create response: $createResponse');
      print('DEBUG: Create response type: ${createResponse.runtimeType}');

      if (createResponse is Map<String, dynamic> &&
          createResponse['id'] != null) {
        final idValue = createResponse['id'];
        print(
          'DEBUG: Created ID value: $idValue, type: ${idValue.runtimeType}',
        );

        // Ensure we have a valid UUID string
        if (idValue is String &&
            idValue.isNotEmpty &&
            !idValue.contains('select')) {
          print('DEBUG: Created new area ID: $idValue');
          return idValue;
        } else {
          print('DEBUG: Invalid created ID format: $idValue');
          throw Exception('ID được tạo không hợp lệ: $idValue');
        }
      } else {
        throw Exception('Không thể tạo khu vực mới - response không hợp lệ');
      }
    } catch (e) {
      print('DEBUG: Error resolving area "$areaName": $e');
      throw Exception('Lỗi khi xử lý khu vực "$areaName": $e');
    }
  }

  /// Resolve waste type name to ID, create if not exists
  Future<String> resolveWasteTypeId(String wasteTypeName, String unit) async {
    // Sanitize inputs first
    final sanitizedName = ValueSanitizer.sanitizeString(wasteTypeName);
    final sanitizedUnit = ValueSanitizer.sanitizeString(unit);

    if (sanitizedName.isEmpty) {
      throw Exception('Tên loại chất thải không được để trống');
    }

    try {
      print(
        'DEBUG: Resolving waste type: "$sanitizedName" (original: "$wasteTypeName")',
      );

      // Tìm waste type theo tên
      final response = await supabase
          .from('waste_types')
          .select('id')
          .eq('name', sanitizedName)
          .maybeSingle();

      print('DEBUG: Waste type search response: $response');
      print('DEBUG: Response type: ${response.runtimeType}');

      if (response != null &&
          response is Map<String, dynamic> &&
          response['id'] != null) {
        final idValue = response['id'];
        print('DEBUG: ID value: $idValue, type: ${idValue.runtimeType}');

        // Ensure we have a valid UUID string
        if (idValue is String &&
            idValue.isNotEmpty &&
            !idValue.contains('select')) {
          print('DEBUG: Found existing waste type ID: $idValue');
          return idValue;
        } else {
          print('DEBUG: Invalid ID format: $idValue');
          throw Exception('ID không hợp lệ từ database: $idValue');
        }
      }

      // Nếu không tìm thấy, tạo mới
      print('DEBUG: Creating new waste type: "$sanitizedName"');
      final createResponse = await supabase
          .from('waste_types')
          .insert({
            'name': sanitizedName,
            'unit': sanitizedUnit.isNotEmpty ? sanitizedUnit : 'kg',
          })
          .select('id')
          .single();

      print('DEBUG: Waste type create response: $createResponse');
      print('DEBUG: Create response type: ${createResponse.runtimeType}');

      if (createResponse is Map<String, dynamic> &&
          createResponse['id'] != null) {
        final idValue = createResponse['id'];
        print(
          'DEBUG: Created ID value: $idValue, type: ${idValue.runtimeType}',
        );

        // Ensure we have a valid UUID string
        if (idValue is String &&
            idValue.isNotEmpty &&
            !idValue.contains('select')) {
          print('DEBUG: Created new waste type ID: $idValue');
          return idValue;
        } else {
          print('DEBUG: Invalid created ID format: $idValue');
          throw Exception('ID được tạo không hợp lệ: $idValue');
        }
      } else {
        throw Exception(
          'Không thể tạo loại chất thải mới - response không hợp lệ',
        );
      }
    } catch (e) {
      print('DEBUG: Error resolving waste type "$wasteTypeName": $e');
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
