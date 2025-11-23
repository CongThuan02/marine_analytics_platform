import 'package:equatable/equatable.dart';

class AreaModel extends Equatable {
  final String? id;
  final String? name;
  final String? createAt;

  const AreaModel({this.id, this.name, this.createAt});

  AreaModel copyWith({String? id, String? name, String? createAt}) {
    return AreaModel(id: id ?? this.id, name: name ?? this.name, createAt: createAt ?? this.createAt);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'create_at': createAt};
  }

  factory AreaModel.fromMap(Map<String, dynamic> map) {
    return AreaModel(id: map['id'] as String, name: map['name'] as String, createAt: map['created_at'] as String);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, createAt];
}
