import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

    return {
      "data": snapshot.docs, // langsung kirim DocumentSnapshot
      "lastDoc": newLastDoc,
    };
  }
}
