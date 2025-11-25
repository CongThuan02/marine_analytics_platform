import 'package:equatable/equatable.dart';

class DepartmentModel extends Equatable {
  final String? id;
  final String? name;
  final String? areaId;
  final String? createdAt;

  const DepartmentModel({this.id, this.name, this.areaId, this.createdAt});

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

  DepartmentModel copyWith({String? id, String? name, String? areaId, String? createdAt}) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      areaId: areaId ?? this.areaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'area_id': areaId, 'created_at': createdAt};
  }

  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    print(map);
    var a = DepartmentModel(id: map['id'], name: map['name'], areaId: map['area_id'], createdAt: map['created_at']);
    print(a);
    return a;
  }

  @override
  List<Object?> get props => [id, name, areaId, createdAt];
}
