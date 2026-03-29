import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/repair/repair_model.dart';
import '../../core/search/search_engine.dart';

class RepairRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final InvertedIndex _searchEngine = InvertedIndex();

  QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;

  bool hasMore = true;

  Future<List<RepairModel>> fetchRepairs({bool refresh = false}) async {
    if (refresh) {
      lastDoc = null;
      hasMore = true;
      _searchEngine.clear();
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

    /// BUILD SEARCH INDEX
    for (var doc in snap.docs) {
      final data = doc.data();

      final List<String> fields = [
        (data['buyerName'] ?? data['buyer'] ?? "").toString(),
        (data['itemName'] ?? data['product'] ?? "").toString(),
        (data['techName'] ?? data['technician'] ?? "").toString(),
        (data['status'] ?? "").toString(),
      ];
      // print("INDEX BUILD: ${doc.id} -> $fields");

      if (fields.any((f) => f.trim().isNotEmpty)) {
        _searchEngine.addDocument(doc.id, fields);
      }
    }

    return snap.docs.map((doc) => RepairModel.fromFirestore(doc)).toList();
  }

  List<String> search(String query) {
    return _searchEngine.search(query).toList();
  }
}
