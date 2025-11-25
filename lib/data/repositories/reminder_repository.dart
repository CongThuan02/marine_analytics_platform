import 'package:marine_analytics_platform/data/models/reminder_model.dart';
import 'package:marine_analytics_platform/global.dart';

class ReminderRepository {
  Future<List<ReminderModel>> fetchAll() async {
    final response = await supabase
        .from('reminders')
        .select('*, departments(name)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ReminderModel.fromJson(json))
        .toList();
  }

  Future<List<ReminderModel>> fetchByDepartment(String departmentId) async {
    final response = await supabase
        .from('reminders')
        .select('*, departments(name)')
        .eq('department_id', departmentId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ReminderModel.fromJson(json))
        .toList();
  }

  Future<ReminderModel> create(ReminderModel reminder) async {
    final response = await supabase
        .from('reminders')
        .insert(reminder.toJson())
        .select('*, departments(name)')
        .single();

    return ReminderModel.fromJson(response);
  }

  Future<ReminderModel> update(String id, ReminderModel reminder) async {
    final response = await supabase
        .from('reminders')
        .update(reminder.toJson())
        .eq('id', id)
        .select('*, departments(name)')
        .single();

    return ReminderModel.fromJson(response);
  }

  Future<void> toggleEnabled(String id, bool enabled) async {
    await supabase.from('reminders').update({'enabled': enabled}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await supabase.from('reminders').delete().eq('id', id);
  }
}
