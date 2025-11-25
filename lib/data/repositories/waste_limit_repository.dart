import 'package:marine_analytics_platform/data/models/waste_limit_model.dart';
import 'package:marine_analytics_platform/global.dart';

class WasteLimitRepository {
  Future<List<WasteLimitModel>> fetchAll() async {
    final response = await supabase
        .from('waste_limits')
        .select('*, areas(name), waste_types(name, unit)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WasteLimitModel.fromJson(json))
        .toList();
  }

  Future<List<WasteLimitModel>> fetchByArea(String areaId) async {
    final response = await supabase
        .from('waste_limits')
        .select('*, areas(name), waste_types(name, unit)')
        .eq('area_id', areaId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => WasteLimitModel.fromJson(json))
        .toList();
  }

  Future<WasteLimitModel> create(WasteLimitModel limit) async {
    final response = await supabase
        .from('waste_limits')
        .insert(limit.toJson())
        .select('*, areas(name), waste_types(name, unit)')
        .single();

    return WasteLimitModel.fromJson(response);
  }

  Future<WasteLimitModel> update(String id, WasteLimitModel limit) async {
    final response = await supabase
        .from('waste_limits')
        .update(limit.toJson())
        .eq('id', id)
        .select('*, areas(name), waste_types(name, unit)')
        .single();

    return WasteLimitModel.fromJson(response);
  }

  Future<void> delete(String id) async {
    await supabase.from('waste_limits').delete().eq('id', id);
  }
}
