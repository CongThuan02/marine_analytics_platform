import 'package:equatable/equatable.dart';

class WasteTypeModel extends Equatable {
  final String? id;
  final String? name;
  final String? unit;
  final String? createAt;

  //<editor-fold desc="Data Methods">
  const WasteTypeModel({this.id = "", this.name = "", this.unit = "", this.createAt = ""});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WasteTypeModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          unit == other.unit &&
          createAt == other.createAt);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ unit.hashCode ^ createAt.hashCode;

  @override
  String toString() {
    return 'WasteType{' + ' id: $id,' + ' name: $name,' + ' unit: $unit,' + ' createAt: $createAt,' + '}';
  }

  WasteTypeModel copyWith({String? id, String? name, String? unit, String? createAt}) {
    return WasteTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      createAt: createAt ?? this.createAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'unit': unit, 'created_at': createAt};
  }

  factory WasteTypeModel.fromMap(Map<String, dynamic> map) {
    return WasteTypeModel(id: map['id'], name: map['name'], unit: map['unit'], createAt: map['created_at']);
  }

  //</editor-fold>
  @override
  List<Object?> get props => [id, name, unit, createAt];
}
