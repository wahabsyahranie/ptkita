import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/core/search/search_engine.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final InvertedIndex _searchEngine = InvertedIndex();

  Future<Map<String, dynamic>> getTransactions({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
    Query query = _db
        .collection('transaction')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    DocumentSnapshot? newLastDoc;

    if (snapshot.docs.isNotEmpty) {
      newLastDoc = snapshot.docs.last;
    }

    /// BUILD INDEX
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final customer = data['customer'] ?? {};
      final summary = data['summary'] ?? {};
      final items = data['items'] ?? [];

      final List<String> fields = [];

      fields.add((customer['name'] ?? "").toString().toLowerCase());
      fields.add((customer['phone'] ?? "").toString().toLowerCase());
      fields.add((summary['txCode'] ?? "").toString().toLowerCase());

      for (var item in items) {
        fields.add((item['name'] ?? "").toString().toLowerCase());
      }

      if (fields.any((f) => f.trim().isNotEmpty)) {
        _searchEngine.addDocument(doc.id, fields);
      }
    }

    return {"data": snapshot.docs, "lastDoc": newLastDoc};
  }

  List<String> search(String query) {
    return _searchEngine.search(query).toList();
  }
}
