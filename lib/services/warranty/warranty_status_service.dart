import 'package:cloud_firestore/cloud_firestore.dart';

class WarrantyStatusService {
  static Future<void> autoUpdateExpiredWarranty() async {
    final now = Timestamp.fromDate(DateTime.now());

    final snapshot = await FirebaseFirestore.instance
        .collection('warranty')
        .where('status', isEqualTo: 'Active')
        .where('expireAt', isLessThan: now)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'status': 'Expired'});
    }
  }
}
