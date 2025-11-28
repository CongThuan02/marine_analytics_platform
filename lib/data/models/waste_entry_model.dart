import 'package:marine_analytics_platform/domain/entities/waste_entry.dart';

class WasteEntryModel extends WasteEntry {
  const WasteEntryModel({
    required super.id,
    required super.userId,
    required super.departmentId,
    required super.areaId,
    required super.wasteTypeId,
    required super.quantity,
    required super.date,
    super.qrCode,
    required super.createdAt,
    super.areaName,
    super.departmentName,
    super.wasteTypeName,
    super.wasteTypeUnit,
  });

  factory WasteEntryModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    final areas = map['areas'] as Map<String, dynamic>?;
    final departments = map['departments'] as Map<String, dynamic>?;
    final wasteTypes = map['waste_types'] as Map<String, dynamic>?;

    return WasteEntryModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      departmentId: map['department_id'] as String? ?? '',
      areaId: map['area_id'] as String? ?? '',
      wasteTypeId: map['waste_type_id'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(map['date']),
      qrCode: map['qr_code'] as String?,
      createdAt: parseDate(map['created_at']),
      areaName: areas?['name'] as String?,
      departmentName: departments?['name'] as String?,
      wasteTypeName: wasteTypes?['name'] as String?,
      wasteTypeUnit: wasteTypes?['unit'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'department_id': departmentId,
      'area_id': areaId,
      'waste_type_id': wasteTypeId,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'qr_code': qrCode,
    };
  }

  factory WasteEntryModel.fromEntity(WasteEntry entity) {
    return WasteEntryModel(
      id: entity.id,
      userId: entity.userId,
      departmentId: entity.departmentId,
      areaId: entity.areaId,
      wasteTypeId: entity.wasteTypeId,
      quantity: entity.quantity,
      date: entity.date,
      qrCode: entity.qrCode,
      createdAt: entity.createdAt,
      areaName: entity.areaName,
      departmentName: entity.departmentName,
      wasteTypeName: entity.wasteTypeName,
      wasteTypeUnit: entity.wasteTypeUnit,
    );
  }
}
