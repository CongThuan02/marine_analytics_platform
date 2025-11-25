import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/data/models/area_model.dart';

class DepartmentModel extends Equatable {
  final String? id;
  final String? name;
  final String? areaId;
  final String? createdAt;
  final AreaModel? areaModel;

  const DepartmentModel({this.id, this.name, this.areaId, this.createdAt, this.areaModel});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DepartmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          areaId == other.areaId &&
          createdAt == other.createdAt);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ areaId.hashCode ^ createdAt.hashCode;

  @override
  String toString() {
    return 'DepartmentModel{' + ' id: $id,' + ' name: $name,' + ' areaId: $areaId,' + ' createdAt: $createdAt,' + '}';
  }

  DepartmentModel copyWith({String? id, String? name, String? areaId, String? createdAt, AreaModel? areaModel}) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      areaId: areaId ?? this.areaId,
      createdAt: createdAt ?? this.createdAt,
      areaModel: areaModel ?? this.areaModel,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'area_id': areaId, 'created_at': createdAt};
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      id: map['id'],
      name: map['name'],
      areaId: map['area_id'],
      createdAt: map['created_at'],
      areaModel: map['areas'] != null ? AreaModel.fromMap(map['areas']) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, areaId, createdAt];
}
