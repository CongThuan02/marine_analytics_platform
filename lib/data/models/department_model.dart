import 'package:marine_analytics_platform/data/models/area_model.dart';
import 'package:marine_analytics_platform/domain/entities/department.dart';

class DepartmentModel extends Department {
  const DepartmentModel({
    required super.id,
    required super.name,
    super.areaId, // Optional
    required super.createdAt,
    super.area,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      areaId: map['area_id'] as String?, // Can be null
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      area: map['areas'] != null ? AreaModel.fromMap(map['areas']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area_id': areaId, // Will be null if not set
    };
  }

  factory DepartmentModel.fromEntity(Department entity) {
    return DepartmentModel(
      id: entity.id,
      name: entity.name,
      areaId: entity.areaId,
      createdAt: entity.createdAt,
      area: entity.area,
    );
  }
}
