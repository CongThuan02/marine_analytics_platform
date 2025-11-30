import 'package:marine_analytics_platform/domain/entities/alert.dart';

class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.areaId,
    required super.wasteTypeId,
    required super.totalToday,
    required super.limitValue,
    required super.percent,
    super.message,
    required super.createdAt,
    super.areaName,
    super.wasteTypeName,
    super.wasteTypeUnit,
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
}
