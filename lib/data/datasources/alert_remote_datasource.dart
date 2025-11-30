import 'package:marine_analytics_platform/data/models/alert_model.dart';
import 'package:marine_analytics_platform/global.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertModel>> fetchAll();
  Future<List<AlertModel>> fetchByArea(String areaId);
  Future<AlertModel> fetchById(String id);
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  @override
  Future<List<AlertModel>> fetchAll() async {
    final response = await supabase
        .from('alerts')
        .select('*, areas(name), waste_types(name, unit)')
        .order('created_at', ascending: false);

    return (response as List).map((json) => AlertModel.fromJson(json)).toList();
  }

  @override
  Future<List<AlertModel>> fetchByArea(String areaId) async {
    final response = await supabase
        .from('alerts')
        .select('*, areas(name), waste_types(name, unit)')
        .eq('area_id', areaId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => AlertModel.fromJson(json)).toList();
  }

  @override
  Future<AlertModel> fetchById(String id) async {
    final response = await supabase
        .from('alerts')
        .select('*, areas(name), waste_types(name, unit)')
        .eq('id', id)
        .single();

    return AlertModel.fromJson(response);
  }
}
