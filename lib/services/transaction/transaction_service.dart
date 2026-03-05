import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction/cart_item_model.dart';
import 'package:flutter_kita/services/warranty/warranty_service.dart';

class TransactionService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final WarrantyService warrantyService = WarrantyService();

  Future<String> generateTxCode() async {
    final year = DateTime.now().year;
    final counterRef = db.collection('counters').doc('tx_$year');

    return db.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int current = 0;

      if (snapshot.exists) {
        current = snapshot['value'] as int;
      }

      final next = current + 1;

      transaction.set(counterRef, {'value': next}, SetOptions(merge: true));

      final number = next.toString().padLeft(5, '0');

      return 'TX-$year-$number';
    });
  }

  Future<void> createTransaction({
    required String name,
    required String phone,
    required DateTime date,
    required List<CartItemModel> items,
  }) async {
    final txRef = db.collection('transaction').doc();

    final transactionId = txRef.id;

    final totalQty = items.fold<int>(0, (s, e) => s + e.qty);

    final subtotal = items.fold<int>(0, (s, e) => s + e.subtotal);

    final txCode = await generateTxCode();

    await txRef.set({
      'customer': {'name': name, 'phone': phone},
      'date': Timestamp.fromDate(date),

      'items': items.map((e) => e.toMap()).toList(),

      'summary': {'subtotal': subtotal, 'totalQty': totalQty, 'txCode': txCode},

      'status': 'Sudah Dibayar',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await warrantyService.createWarrantiesFromTransaction(
      transactionId: transactionId,
      buyerName: name,
      phone: phone,
      items: items,
      transactionDate: date,
    );

    for (final item in items) {
      await db.collection('items').doc(item.itemId).update({
        'stock': FieldValue.increment(-item.qty),
      });
    }
  }
}
