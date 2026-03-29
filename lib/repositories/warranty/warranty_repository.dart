import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/warranty/warranty_model.dart';
import '../../core/search/search_engine.dart';

class WarrantyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final InvertedIndex _searchEngine = InvertedIndex();

  Future<Map<String, dynamic>> getWarranties({
    DocumentSnapshot? lastDoc,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) {
      _searchEngine.clear();
    }

    Query query = _firestore
        .collection('warranty')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();

    /// BUILD SEARCH INDEX
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final List<String> fields = [
        (data['buyerName'] ?? "").toString().toLowerCase(),
        (data['phone'] ?? "").toString().toLowerCase(),
        (data['productName'] ?? "").toString().toLowerCase(),
        (data['serialNumber'] ?? "").toString().toLowerCase(),
        (data['transactionId'] ?? "").toString().toLowerCase(),
      ];

      if (fields.any((f) => f.trim().isNotEmpty)) {
        _searchEngine.addDocument(doc.id, fields);
      }
    }

    final warranties = snapshot.docs
        .map((doc) => WarrantyModel.fromFirestore(doc))
        .toList();

    DocumentSnapshot? newLastDoc;

    if (snapshot.docs.isNotEmpty) {
      newLastDoc = snapshot.docs.last;
    }

    return {"data": warranties, "lastDoc": newLastDoc};
  }

  List<String> search(String query) {
    return _searchEngine.search(query.toLowerCase()).toList();
  }
}
