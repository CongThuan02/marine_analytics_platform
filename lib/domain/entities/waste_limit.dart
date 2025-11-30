import 'package:equatable/equatable.dart';

class WasteLimit extends Equatable {
  final String id;
  final String areaId;
  final String wasteTypeId;
  final double dailyLimit;
  final DateTime createdAt;
  final String? areaName;
  final String? wasteTypeName;
  final String? wasteTypeUnit;

  const WasteLimit({
    required this.id,
    required this.areaId,
    required this.wasteTypeId,
    required this.dailyLimit,
    required this.createdAt,
    this.areaName,
    this.wasteTypeName,
    this.wasteTypeUnit,
  });

  @override
  List<Object?> get props => [
        id,
        areaId,
        wasteTypeId,
        dailyLimit,
        createdAt,
        areaName,
        wasteTypeName,
        wasteTypeUnit,
      ];
}
