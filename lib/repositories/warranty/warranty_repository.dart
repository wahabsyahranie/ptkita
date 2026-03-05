import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/warranty/warranty_model.dart';

class WarrantyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    final warranties = snapshot.docs
        .map((doc) => WarrantyModel.fromFirestore(doc))
        .toList();

    DocumentSnapshot? newLastDoc;

    if (snapshot.docs.isNotEmpty) {
      newLastDoc = snapshot.docs.last;
    }

    return {"data": warranties, "lastDoc": newLastDoc};
  }
}
