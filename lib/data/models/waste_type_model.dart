import 'package:marine_analytics_platform/domain/entities/waste_type.dart';

class WasteTypeModel extends WasteType {
  const WasteTypeModel({
    required super.id,
    required super.name,
    required super.unit,
    required super.createdAt,
  });

  factory WasteTypeModel.fromMap(Map<String, dynamic> map) {
    return WasteTypeModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
    };
  }

  factory WasteTypeModel.fromEntity(WasteType entity) {
    return WasteTypeModel(
      id: entity.id,
      name: entity.name,
      unit: entity.unit,
      createdAt: entity.createdAt,
    );
  }
}
