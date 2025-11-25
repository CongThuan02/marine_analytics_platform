import 'package:equatable/equatable.dart';

class AlertModel extends Equatable {
  final String id;
  final String areaId;
  final String wasteTypeId;
  final double totalToday;
  final double limitValue;
  final double percent;
  final String? message;
  final DateTime createdAt;
  
  // Joined data
  final String? areaName;
  final String? wasteTypeName;
  final String? wasteTypeUnit;

  const AlertModel({
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

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      areaId: json['area_id'] as String,
      wasteTypeId: json['waste_type_id'] as String,
      totalToday: (json['total_today'] as num).toDouble(),
      limitValue: (json['limit_value'] as num).toDouble(),
      percent: (json['percent'] as num).toDouble(),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      areaName: json['areas']?['name'] as String?,
      wasteTypeName: json['waste_types']?['name'] as String?,
      wasteTypeUnit: json['waste_types']?['unit'] as String?,
    );
  }

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

enum AlertLevel {
  info,
  warning,
  critical,
}
