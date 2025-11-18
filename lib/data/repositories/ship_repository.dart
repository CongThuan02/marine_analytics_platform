import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ship_model.dart';

class ShipRepository {
  final FirebaseFirestore firestore;

  ShipRepository(this.firestore);

  Future<List<ShipModel>> getAllShips() async {
    final query = await firestore.collection("ships").get();

    return query.docs.map((doc) => ShipModel.fromFirestore(doc.id, doc.data())).toList();
  }
}
