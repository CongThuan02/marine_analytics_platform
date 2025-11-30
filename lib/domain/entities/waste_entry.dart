import 'package:equatable/equatable.dart';

class WasteEntry extends Equatable {
  final String id;
  final String userId;
  final String departmentId;
  final String areaId;
  final String wasteTypeId;
  final double quantity;
  final DateTime date;
  final String? qrCode;
  final DateTime createdAt;
  final String? areaName;
  final String? departmentName;
  final String? wasteTypeName;
  final String? wasteTypeUnit;

  const WasteEntry({
    required this.id,
    required this.userId,
    required this.departmentId,
    required this.areaId,
    required this.wasteTypeId,
    required this.quantity,
    required this.date,
    this.qrCode,
    required this.createdAt,
    this.areaName,
    this.departmentName,
    this.wasteTypeName,
    this.wasteTypeUnit,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        departmentId,
        areaId,
        wasteTypeId,
        quantity,
        date,
        qrCode,
        createdAt,
        areaName,
        departmentName,
        wasteTypeName,
        wasteTypeUnit,
      ];
}
