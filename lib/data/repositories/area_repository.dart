import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/global.dart';

class AreaRepository {
  Future<String> CreateArea({required AreaModel area}) async {
    try {
      final res = await supabase.from('areas').insert({'name': area.name});
      return "Thêm dữ liệu thành công";
    } catch (e) {
      return "Thêm dữ liệu thất bại ${e}";
    }
  }

  Future<List<AreaModel>?> getAllArea() async {
    try {
      final res = await supabase.from('areas').select();

      final List<AreaModel> data = res.map((e) => AreaModel.fromMap(e)).toList();
      print(data);
      return data;
    } catch (e) {
      print(e);
    }
  }
}
