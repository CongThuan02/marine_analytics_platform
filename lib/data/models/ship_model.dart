import 'package:cloud_firestore/cloud_firestore.dart';

class ShipModel {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;

  ShipModel({required this.id, required this.name, required this.type, required this.createdAt});

  factory ShipModel.fromFirestore(String id, Map<String, dynamic> json) {
    return ShipModel(id: id, name: json['name'] ?? '', type: json['type'] ?? '', createdAt: (json['createdAt'] as Timestamp).toDate());
  }
}
