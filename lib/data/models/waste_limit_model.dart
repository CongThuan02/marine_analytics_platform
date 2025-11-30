import 'package:marine_analytics_platform/domain/entities/waste_limit.dart';

class WasteLimitModel extends WasteLimit {
  const WasteLimitModel({
    required super.id,
    required super.areaId,
    required super.wasteTypeId,
    required super.dailyLimit,
    required super.createdAt,
    super.areaName,
    super.wasteTypeName,
    super.wasteTypeUnit,
  });

  factory WasteLimitModel.fromJson(Map<String, dynamic> json) {
    return WasteLimitModel(
      id: json['id'] as String,
      areaId: json['area_id'] as String,
      wasteTypeId: json['waste_type_id'] as String,
      dailyLimit: (json['daily_limit'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      areaName: json['areas']?['name'] as String?,
      wasteTypeName: json['waste_types']?['name'] as String?,
      wasteTypeUnit: json['waste_types']?['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'waste_type_id': wasteTypeId,
      'daily_limit': dailyLimit,
    };
  }

  factory WasteLimitModel.fromEntity(WasteLimit entity) {
    return WasteLimitModel(
      id: entity.id,
      areaId: entity.areaId,
      wasteTypeId: entity.wasteTypeId,
      dailyLimit: entity.dailyLimit,
      createdAt: entity.createdAt,
      areaName: entity.areaName,
      wasteTypeName: entity.wasteTypeName,
      wasteTypeUnit: entity.wasteTypeUnit,
    );
  }
}
