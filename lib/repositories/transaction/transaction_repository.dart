import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/core/search/search_engine.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final InvertedIndex _searchEngine = InvertedIndex();
  bool _globalIndexLoaded = false;

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

    // print("JUMLAH DATA: ${snapshot.docs.length}");

    DocumentSnapshot? newLastDoc;

    if (snapshot.docs.isNotEmpty) {
      newLastDoc = snapshot.docs.last;
    }

    /// Menyiapkan field yang akan diindeks ke dalam Inverted Index
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
        // print("DOC ID: ${doc.id}");
        // print("FIELDS: $fields");
        _searchEngine.addDocument(doc.id, fields);
      }
    }

    return {"data": snapshot.docs, "lastDoc": newLastDoc};
  }

  List<String> search(String query) {
    return _searchEngine.search(query).toList();
  }

  Future<void> buildGlobalIndex() async {
    if (_globalIndexLoaded) return;

    final snapshot = await _db.collection('transaction').get();

    _searchEngine.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();

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

    _globalIndexLoaded = true;
  }

  Future<List<DocumentSnapshot>> getAllTransactions() async {
    final snapshot = await _db
        .collection('transaction')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs;
  }
}
