import 'package:marine_analytics_platform/domain/entities/area.dart';

class AreaModel extends Area {
  const AreaModel({
    required super.id,
    required super.name,
    required super.createdAt,
  });

  factory AreaModel.fromMap(Map<String, dynamic> map) {
    return AreaModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory AreaModel.fromEntity(Area entity) {
    return AreaModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }
}
