import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/global.dart';

class Department {
  Future<String> CreateArea({required DepartmentModel area}) async {
    try {
      await supabase.from('departments').insert({'name': area.name, 'area_id': area.areaId});
      return "Thêm dữ liệu thành công";
    } catch (e) {
      return "Thêm dữ liệu thất bại ${e}";
    }
  }
}