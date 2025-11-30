import 'package:equatable/equatable.dart';

enum AlertLevel {
  info,
  warning,
  critical,
}

class Alert extends Equatable {
  final String id;
  final String areaId;
  final String wasteTypeId;
  final double totalToday;
  final double limitValue;
  final double percent;
  final String? message;
  final DateTime createdAt;
  final String? areaName;
  final String? wasteTypeName;
  final String? wasteTypeUnit;

  const Alert({
    required this.id,
    required this.areaId,
    required this.wasteTypeId,
    required this.totalToday,
    required this.limitValue,
    required this.percent,
    this.message,
    required this.createdAt,
    this.areaName,
    this.wasteTypeName,
    this.wasteTypeUnit,
  });

  AlertLevel get level {
    if (percent >= 100) return AlertLevel.critical;
    if (percent >= 80) return AlertLevel.warning;
    return AlertLevel.info;
  }

  @override
  List<Object?> get props => [
        id,
        areaId,
        wasteTypeId,
        totalToday,
        limitValue,
        percent,
        message,
        createdAt,
        areaName,
        wasteTypeName,
        wasteTypeUnit,
      ];
}
