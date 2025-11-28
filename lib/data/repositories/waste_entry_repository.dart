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

      return (response as List<dynamic>)
          .map((item) => WasteEntryModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Unable to load waste history: $e');
    }
  }

  Future<String> createWasteEntry({required WasteEntryModel entry}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You are not logged in.');
    }

    if (entry.areaId == null || entry.areaId!.isEmpty) {
      throw Exception('Please select an area.');
    }
    if (entry.departmentId == null || entry.departmentId!.isEmpty) {
      throw Exception('Please select a department.');
    }
    if (entry.wasteTypeId == null || entry.wasteTypeId!.isEmpty) {
      throw Exception('Please select a waste type.');
    }
    if (entry.quantity == null || entry.quantity! <= 0) {
      throw Exception('Quantity must be greater than 0.');
    }
    if (entry.date == null) {
      throw Exception('Please select entry date.');
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
      'date': formatDate(entry.date!),
      'qr_code': (entry.qrCode?.isNotEmpty ?? false) ? entry.qrCode : null,
    };

    try {
      await supabase.from('waste_entries').insert(payload);
      return 'Waste recorded successfully.';
    } catch (e) {
      print(e);
      throw Exception('Unable to save data: $e');
    }
  }
}
