import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/global.dart';
import 'package:marine_analytics_platform/presentation/blocs/department/department_bloc.dart';

class DepartmentRepository {
  Future<String> CreateDepartment({required DepartmentModel department}) async {
    try {
      await supabase.from('departments').insert({'name': department.name, 'area_id': department.areaId});
      return "Thêm dữ liệu thành công";
    } catch (e) {
      return "Thêm dữ liệu thất bại ${e}";
    }
  }
}
