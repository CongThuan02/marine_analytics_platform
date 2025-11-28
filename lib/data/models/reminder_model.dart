import 'package:marine_analytics_platform/domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.departmentId,
    required super.timeOfDay,
    required super.frequency,
    super.message,
    required super.enabled,
    required super.createdAt,
    super.departmentName,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      departmentId: json['department_id'] as String,
      timeOfDay: json['time_of_day'] as String,
      frequency: json['frequency'] as String,
      message: json['message'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      departmentName: json['departments']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_id': departmentId,
      'time_of_day': timeOfDay,
      'frequency': frequency,
      'message': message,
      'enabled': enabled,
    };
  }

  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      departmentId: entity.departmentId,
      timeOfDay: entity.timeOfDay,
      frequency: entity.frequency,
      message: entity.message,
      enabled: entity.enabled,
      createdAt: entity.createdAt,
      departmentName: entity.departmentName,
    );
  }
}
