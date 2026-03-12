import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction/cart_item_model.dart';
import 'package:flutter_kita/models/warranty/warranty_model.dart';

class WarrantyService {
  final _firestore = FirebaseFirestore.instance;

  /// digunakan oleh fitur tambah warranty manual
  Future<void> addWarranty(WarrantyModel warranty) async {
    await _firestore.collection('warranty').add(warranty.toMap());
  }

  /// digunakan oleh fitur transaksi
  Future<void> createWarrantiesFromTransaction({
    required String transactionId,
    required String buyerName,
    required String phone,
    required List<CartItemModel> items,
    required DateTime transactionDate,
  }) async {
    final warrantyRef = _firestore.collection('warranty');

    for (final item in items) {
      if (!item.hasWarranty) continue;

      final int duration = item.warrantyYear;

      if (duration <= 0) continue;

      final int qty = item.qty;

      for (int i = 0; i < qty; i++) {
        final startAt = transactionDate;

        final expireAt = DateTime(
          transactionDate.year + duration,
          transactionDate.month,
          transactionDate.day,
        );

        final serial = item.serialNumbers.isNotEmpty
            ? item.serialNumbers[i]
            : '';

        await warrantyRef.add({
          'transactionId': transactionId,
          'itemId': item.itemId,
          'buyerName': buyerName,
          'phone': phone,
          'productName': item.name,

          'serialNumber': serial,

          'warrantyType': item.warrantyType,

          'startAt': Timestamp.fromDate(startAt),
          'expireAt': Timestamp.fromDate(expireAt),
          'createdAt': FieldValue.serverTimestamp(),

          'status': 'Active',
          'claimCount': 0,
        });
      }
    }
  }
}
