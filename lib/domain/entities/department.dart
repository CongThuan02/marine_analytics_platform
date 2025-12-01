import 'package:equatable/equatable.dart';
import 'package:marine_analytics_platform/domain/entities/area.dart';

class Department extends Equatable {
  final String id;
  final String name;
  final String? areaId; // Nullable - department can exist without area
  final DateTime createdAt;
  final Area? area;

  const Department({
    required this.id,
    required this.name,
    this.areaId, // Optional
    required this.createdAt,
    this.area,
  });

  @override
  List<Object?> get props => [id, name, areaId, createdAt, area];
}
