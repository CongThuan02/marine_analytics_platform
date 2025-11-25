import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final String departmentId;
  final String timeOfDay; // HH:mm:ss
  final String frequency; // 'daily' or 'weekly'
  final String? message;
  final bool enabled;
  final DateTime createdAt;
  
  // Joined data
  final String? departmentName;

  const ReminderModel({
    required this.id,
    required this.departmentId,
    required this.timeOfDay,
    required this.frequency,
    this.message,
    required this.enabled,
    required this.createdAt,
    this.departmentName,
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

  ReminderModel copyWith({
    String? id,
    String? departmentId,
    String? timeOfDay,
    String? frequency,
    String? message,
    bool? enabled,
    DateTime? createdAt,
    String? departmentName,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      frequency: frequency ?? this.frequency,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      departmentName: departmentName ?? this.departmentName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        departmentId,
        timeOfDay,
        frequency,
        message,
        enabled,
        createdAt,
        departmentName,
      ];
}
