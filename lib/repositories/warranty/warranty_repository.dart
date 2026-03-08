import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/warranty/warranty_model.dart';
import '../../core/search/search_engine.dart';

class WarrantyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final InvertedIndex _searchEngine = InvertedIndex();

  Future<Map<String, dynamic>> getWarranties({
    DocumentSnapshot? lastDoc,
    int limit = 20,
  }) async {
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
        data['buyerName'] ?? "",
        data['phone'] ?? "",
        data['productName'] ?? "",
        data['serialNumber'] ?? "",
        data['transactionId'] ?? "",
      ];

      _searchEngine.addDocument(doc.id, fields);
    }

    /// CONVERT TO MODEL
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
    return _searchEngine.search(query).toList();
  }
}
