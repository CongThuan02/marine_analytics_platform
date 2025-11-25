import 'package:equatable/equatable.dart';

class WasteEntryModel extends Equatable {
  final String? id;
  final String? userId;
  final String? departmentId;
  final String? areaId;
  final String? wasteTypeId;
  final double? quantity;
  final DateTime? date;
  final String? qrCode;
  final DateTime? createdAt;
  final String? areaName;
  final String? departmentName;
  final String? wasteTypeName;
  final String? wasteTypeUnit;

  const WasteEntryModel({
    this.id,
    this.userId,
    this.departmentId,
    this.areaId,
    this.wasteTypeId,
    this.quantity,
    this.date,
    this.qrCode,
    this.createdAt,
    this.areaName,
    this.departmentName,
    this.wasteTypeName,
    this.wasteTypeUnit,
  });

  WasteEntryModel copyWith({
    String? id,
    String? userId,
    String? departmentId,
    String? areaId,
    String? wasteTypeId,
    double? quantity,
    DateTime? date,
    String? qrCode,
    DateTime? createdAt,
    String? areaName,
    String? departmentName,
    String? wasteTypeName,
    String? wasteTypeUnit,
  }) {
    return WasteEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      departmentId: departmentId ?? this.departmentId,
      areaId: areaId ?? this.areaId,
      wasteTypeId: wasteTypeId ?? this.wasteTypeId,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      areaName: areaName ?? this.areaName,
      departmentName: departmentName ?? this.departmentName,
      wasteTypeName: wasteTypeName ?? this.wasteTypeName,
      wasteTypeUnit: wasteTypeUnit ?? this.wasteTypeUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'department_id': departmentId,
      'area_id': areaId,
      'waste_type_id': wasteTypeId,
      'quantity': quantity,
      'date': date?.toIso8601String(),
      'qr_code': qrCode,
      'created_at': createdAt?.toIso8601String(),
      'area_name': areaName,
      'department_name': departmentName,
      'waste_type_name': wasteTypeName,
      'waste_type_unit': wasteTypeUnit,
    };
  }

  factory WasteEntryModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    final areas = map['areas'] as Map<String, dynamic>?;
    final departments = map['departments'] as Map<String, dynamic>?;
    final wasteTypes = map['waste_types'] as Map<String, dynamic>?;

    return WasteEntryModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      departmentId: map['department_id'] as String?,
      areaId: map['area_id'] as String?,
      wasteTypeId: map['waste_type_id'] as String?,
      quantity: (map['quantity'] as num?)?.toDouble(),
      date: parseDate(map['date']),
      qrCode: map['qr_code'] as String?,
      createdAt: parseDate(map['created_at']),
      areaName: areas?['name'] as String?,
      departmentName: departments?['name'] as String?,
      wasteTypeName: wasteTypes?['name'] as String?,
      wasteTypeUnit: wasteTypes?['unit'] as String?,
    );
  }

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

