import 'package:marine_analytics_platform/data/models/waste_type_model.dart';
import 'package:marine_analytics_platform/global.dart';

class WasteTypeRepository {
  Future<String> createWasteType({required WasteTypeModel wasteType}) async {
    try {
      await supabase.from('waste_types').insert({'name': wasteType.name, 'unit': wasteType.unit});
      return "Thêm dữ liệu thành công";
    } catch (e) {
      return "Thêm dữ liệu thất bại ${e}";
    }
  }

  Future<List<WasteTypeModel>?> getWasteType() async {
    try {
      final res = await supabase.from('waste_types').select();
      if (res != []) {
        List<WasteTypeModel> data = res.map((e) => WasteTypeModel.fromMap(e)).toList();
        return data;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String> deleteWasteType({required String id}) async {
    try {
      await supabase.from('waste_types').delete().eq('id', id);
      return "Xoá phòng ban thành công";
    } catch (e) {
      return "Xóa thất bại";
    }
  }
}
