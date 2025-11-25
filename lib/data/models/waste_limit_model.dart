import 'package:equatable/equatable.dart';

class WasteLimitModel extends Equatable {
  final String id;
  final String areaId;
  final String wasteTypeId;
  final double dailyLimit;
  final DateTime createdAt;
  
  // Joined data
  final String? areaName;
  final String? wasteTypeName;
  final String? wasteTypeUnit;

  const WasteLimitModel({
    required this.id,
    required this.areaId,
    required this.wasteTypeId,
    required this.dailyLimit,
    required this.createdAt,
    this.areaName,
    this.wasteTypeName,
    this.wasteTypeUnit,
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

  @override
  List<Object?> get props => [
        id,
        areaId,
        wasteTypeId,
        dailyLimit,
        createdAt,
        areaName,
        wasteTypeName,
        wasteTypeUnit,
      ];
}
