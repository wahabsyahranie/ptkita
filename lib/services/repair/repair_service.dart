import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RepairService {
  static Future<Map<String, dynamic>> markSelesai({
    required String docId,
    required String detail,
    required int cost,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    String completedByName = 'Unknown';

    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      completedByName = userDoc.data()?['name'] ?? 'Unknown';
    }

    await FirebaseFirestore.instance.collection('repair').doc(docId).update({
      'status': 'Selesai',
      'detailPart': detail,
      'cost': cost,
      'completedAt': FieldValue.serverTimestamp(),
      'completedByName': completedByName,
      'completedByUid': uid,
    });

    return {'completedByName': completedByName, 'completedAt': Timestamp.now()};
  }
}
