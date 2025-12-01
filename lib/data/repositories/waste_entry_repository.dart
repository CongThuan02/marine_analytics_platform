import 'package:marine_analytics_platform/core/services/local_notification_service.dart';
import 'package:marine_analytics_platform/data/models/waste_entry_model.dart';
import 'package:marine_analytics_platform/global.dart';

class WasteEntryRepository {
  Future<List<WasteEntryModel>> fetchWasteEntries() async {
    try {
      final response = await supabase
          .from('waste_entries')
          .select('''
        id,
        user_id,
        department_id,
        area_id,
        waste_type_id,
        quantity,
        date,
        qr_code,
        created_at,
        departments(id, name),
        areas(id, name),
        waste_types(id, name, unit)
        ''')
          .order('date', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((item) => WasteEntryModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Không thể tải lịch sử rác thải: $e');
    }
  }

  Future<String> createWasteEntry({required WasteEntryModel entry}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    if (entry.areaId.isEmpty) {
      throw Exception('Vui lòng chọn khu vực.');
    }
    if (entry.departmentId.isEmpty) {
      throw Exception('Vui lòng chọn phòng.');
    }
    if (entry.wasteTypeId.isEmpty) {
      throw Exception('Vui lòng chọn loại chất thải.');
    }
    if (entry.quantity <= 0) {
      throw Exception('Số lượng phải lớn hơn 0.');
    }

    String formatDate(DateTime date) {
      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }

    final payload = {
      'user_id': userId,
      'department_id': entry.departmentId,
      'area_id': entry.areaId,
      'waste_type_id': entry.wasteTypeId,
      'quantity': entry.quantity,
      'date': formatDate(entry.date),
      'qr_code': (entry.qrCode?.isNotEmpty ?? false) ? entry.qrCode : null,
    };

    try {
      print('💾 [SAVE] Inserting waste entry...');
      await supabase.from('waste_entries').insert(payload);
      print('✅ [SAVE] Waste entry saved successfully');

      // Check waste limit and show notification if exceeded
      print('🔔 [SAVE] Starting waste limit check...');
      await _checkWasteLimitAndNotify(entry);
      print('✅ [SAVE] Waste limit check completed');

      return 'Đã ghi nhận rác thải thành công.';
    } catch (e) {
      print('❌ [SAVE] Lỗi: $e');
      throw Exception('Không thể lưu dữ liệu: $e');
    }
  }

  Future<String> updateWasteEntry({required String id, required WasteEntryModel entry}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    if (entry.areaId.isEmpty) {
      throw Exception('Vui lòng chọn khu vực.');
    }
    if (entry.departmentId.isEmpty) {
      throw Exception('Vui lòng chọn phòng.');
    }
    if (entry.wasteTypeId.isEmpty) {
      throw Exception('Vui lòng chọn loại chất thải.');
    }
    if (entry.quantity <= 0) {
      throw Exception('Số lượng phải lớn hơn 0.');
    }

    String formatDate(DateTime date) {
      final year = date.year.toString().padLeft(4, '0');
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }

    final payload = {
      'department_id': entry.departmentId,
      'area_id': entry.areaId,
      'waste_type_id': entry.wasteTypeId,
      'quantity': entry.quantity,
      'date': formatDate(entry.date),
      'qr_code': (entry.qrCode?.isNotEmpty ?? false) ? entry.qrCode : null,
    };

    try {
      print('💾 [UPDATE] Updating waste entry...');
      await supabase.from('waste_entries').update(payload).eq('id', id);
      print('✅ [UPDATE] Waste entry updated successfully');

      // Check waste limit and show notification if exceeded
      print('🔔 [UPDATE] Starting waste limit check...');
      await _checkWasteLimitAndNotify(entry);
      print('✅ [UPDATE] Waste limit check completed');

      return 'Đã cập nhật rác thải thành công.';
    } catch (e) {
      print('❌ [UPDATE] Lỗi: $e');
      throw Exception('Không thể cập nhật dữ liệu: $e');
    }
  }

  /// Check waste limit and show local notification if exceeded
  Future<void> _checkWasteLimitAndNotify(WasteEntryModel entry) async {
    try {
      print('🔍 [WASTE LIMIT CHECK] Starting check...');
      print('   Area ID: ${entry.areaId}');
      print('   Waste Type ID: ${entry.wasteTypeId}');
      print('   Quantity: ${entry.quantity}');

      // Get area and waste type names
      final areaResponse = await supabase.from('areas').select('name').eq('id', entry.areaId).maybeSingle();

      final wasteTypeResponse = await supabase
          .from('waste_types')
          .select('name')
          .eq('id', entry.wasteTypeId)
          .maybeSingle();

      if (areaResponse == null) {
        print('⚠️ [WASTE LIMIT CHECK] Area not found');
        return;
      }

      if (wasteTypeResponse == null) {
        print('⚠️ [WASTE LIMIT CHECK] Waste type not found');
        return;
      }

      final areaName = areaResponse['name'] as String;
      final wasteTypeName = wasteTypeResponse['name'] as String;

      print('✅ [WASTE LIMIT CHECK] Found area: $areaName');
      print('✅ [WASTE LIMIT CHECK] Found waste type: $wasteTypeName');

      // Check and notify
      await LocalNotificationService().checkAndNotifyWasteLimit(
        areaId: entry.areaId,
        wasteTypeId: entry.wasteTypeId,
        quantity: entry.quantity,
        areaName: areaName,
        wasteTypeName: wasteTypeName,
      );

      print('✅ [WASTE LIMIT CHECK] Check completed');
    } catch (e) {
      print('❌ [WASTE LIMIT CHECK] Error: $e');
      // Don't throw error, just log it
    }
  }
}
