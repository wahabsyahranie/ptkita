import 'package:cloud_firestore/cloud_firestore.dart';

class WarrantyModel {
  final String id;
  final String transactionId;
  final String itemId;

  final String buyerName;
  final String phone;

  final String productName;
  final String serialNumber;
  final String warrantyType;

  final DateTime startAt;
  final DateTime expireAt;

  final String status; // Active | Expired
  final int claimCount;

  WarrantyModel({
    required this.id,
    required this.transactionId,
    required this.itemId,
    required this.buyerName,
    required this.phone,
    required this.productName,
    required this.serialNumber,
    required this.warrantyType,
    required this.startAt,
    required this.expireAt,
    required this.status,
    required this.claimCount,
  });

  factory WarrantyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WarrantyModel(
      id: doc.id,
      transactionId: data['transactionId'] ?? '',
      itemId: data['itemId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      phone: data['phone'] ?? '',
      productName: data['productName'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      warrantyType: data['warrantyType'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      expireAt: (data['expireAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'Active',
      claimCount: (data['claimCount'] ?? 0) as int,
    );
  }

  /// 🔥 expired murni berdasarkan waktu
  bool get isExpired {
    return DateTime.now().isAfter(expireAt);
  }

  /// 🔥 active harus status Active DAN belum expired
  bool get isReallyActive {
    return status == 'Active' && !isExpired;
  }

  String get warrantyTypeLabel {
    switch (warrantyType.toLowerCase()) {
      case 'jasa':
      case 'service':
        return 'Garansi Servis Jasa';
      case 'sparepart':
        return 'Garansi Sparepart';
      case 'jasa & sparepart':
      case 'both':
        return 'Garansi Servis Jasa & Sparepart';
      default:
        return 'Garansi';
    }
  }
}
