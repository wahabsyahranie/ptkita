import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/repair/repair_model.dart';

class RepairRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;

  bool hasMore = true;

  Future<List<RepairModel>> fetchRepairs({bool refresh = false}) async {
    if (refresh) {
      lastDoc = null;
      hasMore = true;
    }

    if (!hasMore) return [];

    Query<Map<String, dynamic>> query = _db
        .collection('repair')
        .orderBy('date', descending: true)
        .limit(20);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc!);
    }

    final snap = await query.get();

    if (snap.docs.isNotEmpty) {
      lastDoc = snap.docs.last;
    }

    if (snap.docs.length < 20) {
      hasMore = false;
    }

    return snap.docs.map((doc) => RepairModel.fromFirestore(doc)).toList();
  }
}
