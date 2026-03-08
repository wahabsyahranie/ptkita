import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/repair/repair_model.dart';
import 'package:flutter_kita/repositories/repair/repair_repository.dart';

class RepairHistoryService {
  final _collection = FirebaseFirestore.instance.collection('repair');

  final RepairRepository _repo;

  RepairHistoryService(this._repo);

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

  Future<List<RepairModel>> fetchRepairs({bool refresh = false}) {
    return _repo.fetchRepairs(refresh: refresh);
  }

  List<String> search(String query) {
    return _repo.search(query);
  }

  Future<RepairModel?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;

    return RepairModel.fromFirestore(
      doc as QueryDocumentSnapshot<Map<String, dynamic>>,
    );
  }

  bool get hasMore => _repo.hasMore;
}
