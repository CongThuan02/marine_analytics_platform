import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String departmentId;
  final String timeOfDay;
  final String frequency;
  final String? message;
  final bool enabled;
  final DateTime createdAt;
  final String? departmentName;

  const Reminder({
    required this.id,
    required this.departmentId,
    required this.timeOfDay,
    required this.frequency,
    this.message,
    required this.enabled,
    required this.createdAt,
    this.departmentName,
  });

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
