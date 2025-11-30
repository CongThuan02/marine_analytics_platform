import 'package:marine_analytics_platform/data/models/waste_type_model.dart';
import 'package:marine_analytics_platform/global.dart';

abstract class WasteTypeRemoteDataSource {
  Future<List<WasteTypeModel>> getAll();
  Future<void> create(WasteTypeModel wasteType);
  Future<void> delete(String id);
}

class WasteTypeRemoteDataSourceImpl implements WasteTypeRemoteDataSource {
  @override
  Future<List<WasteTypeModel>> getAll() async {
    final response = await supabase.from('waste_types').select();
    return (response as List).map((e) => WasteTypeModel.fromMap(e)).toList();
  }

  @override
  Future<void> create(WasteTypeModel wasteType) async {
    await supabase.from('waste_types').insert(wasteType.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await supabase.from('waste_types').delete().eq('id', id);
  }
}
