import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/domain/entities/area.dart';

class Department extends Equatable {
  final String id;
  final String name;
  final String areaId;
  final DateTime createdAt;
  final Area? area;

  const Department({
    required this.id,
    required this.name,
    required this.areaId,
    required this.createdAt,
    this.area,
  });

  @override
  List<Object?> get props => [id, name, areaId, createdAt, area];
}
