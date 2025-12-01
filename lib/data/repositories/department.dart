import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/global.dart';

class DepartmentRepository {
  Future<String> createDepartment({required DepartmentModel department}) async {
    try {
      await supabase.from('departments').insert({
        'name': department.name,
        'area_id': department.areaId,
      });
      return "Đã thêm dữ liệu thành công";
    } catch (e) {
      return "Thêm dữ liệu thất bại: $e";
    }
  }

  Future<List<DepartmentModel>?> getDepartment() async {
    try {
      final res = await supabase
          .from('departments')
          .select('id, name, area_id, areas(id, name)'); // Include area_id
      // print(res);
      if (res != []) {
        List<DepartmentModel> data = res
            .map((e) => DepartmentModel.fromMap(e))
            .toList();
        return data;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String> deleteDepartment({required String id}) async {
    try {
      await supabase.from('departments').delete().eq('id', id);
      return "Đã xóa phòng ban thành công";
    } catch (e) {
      return "Xóa thất bại";
    }
  }
}
