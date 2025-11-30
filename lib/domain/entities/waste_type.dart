import 'package:equatable/equatable.dart';

class WasteType extends Equatable {
  final String id;
  final String name;
  final String unit;
  final DateTime createdAt;

  const WasteType({
    required this.id,
    required this.name,
    required this.unit,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, unit, createdAt];
}
