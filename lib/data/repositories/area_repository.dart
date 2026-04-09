import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/global.dart';

class AreaRepository {
  Future<String> CreateArea({required AreaModel area}) async {
    try {
      await supabase.from('areas').insert({'name': area.name});
      return "Đã thêm dữ liệu thành công";
    } catch (e) {
      print(e);
      return "Failed to add data: $e";
    }
  }

  Future<List<AreaModel>?> getAllArea() async {
    try {
      final res = await supabase.from('areas').select();

      final List<AreaModel> data = res
          .map((e) => AreaModel.fromMap(e))
          .toList();
      return data;
    } catch (e) {
      return [];
    }
  }

  Future<String> deleteArea({required String id}) async {
    try {
      var a = await supabase.from('areas').delete().eq('id', id);
      return "Đã xóa khu vực thành công";
    } catch (e) {
      return "Xóa thất bại";
    }
  }

  Future<String> updateArea({required String id, required String name}) async {
    try {
      await supabase.from('areas').update({'name': name}).eq('id', id);
      return "Đã cập nhật khu vực thành công";
    } catch (e) {
      return "Cập nhật thất bại: $e";
    }
  }
}
