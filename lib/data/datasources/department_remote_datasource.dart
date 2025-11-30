import 'package:marine_analytics_platform/data/models/department_model.dart';
import 'package:marine_analytics_platform/global.dart';

abstract class DepartmentRemoteDataSource {
  Future<List<DepartmentModel>> getAll();
  Future<void> create(DepartmentModel department);
  Future<void> delete(String id);
}

class DepartmentRemoteDataSourceImpl implements DepartmentRemoteDataSource {
  @override
  Future<List<DepartmentModel>> getAll() async {
    final response = await supabase
        .from('departments')
        .select('id, name, area_id, created_at, areas(id, name, created_at)');
    return (response as List).map((e) => DepartmentModel.fromMap(e)).toList();
  }

  @override
  Future<void> create(DepartmentModel department) async {
    await supabase.from('departments').insert(department.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('departments').delete().eq('id', id);
  }
}
