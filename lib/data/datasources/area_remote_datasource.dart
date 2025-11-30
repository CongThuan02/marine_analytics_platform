import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/global.dart';

abstract class AreaRemoteDataSource {
  Future<List<AreaModel>> getAll();
  Future<void> create(AreaModel area);
  Future<void> delete(String id);
}

class AreaRemoteDataSourceImpl implements AreaRemoteDataSource {
  @override
  Future<List<AreaModel>> getAll() async {
    final response = await supabase.from('areas').select();
    return (response as List).map((e) => AreaModel.fromMap(e)).toList();
  }

  @override
  Future<void> create(AreaModel area) async {
    await supabase.from('areas').insert(area.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('areas').delete().eq('id', id);
  }
}
