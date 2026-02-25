import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/repair/repair_model.dart';

class RepairHistoryService {
  final _collection = FirebaseFirestore.instance.collection('repair');

  Stream<List<RepairModel>> streamRepairs() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RepairModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<RepairModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    return RepairModel.fromFirestore(
      doc as QueryDocumentSnapshot<Map<String, dynamic>>,
    );
  }
}
