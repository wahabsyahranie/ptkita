import 'package:cloud_firestore/cloud_firestore.dart';

class WarrantyModel {
  final String id;
  final String transactionId;
  final String itemId;
  final String buyerName;
  final String productName;
  final String serialNumber;
  final String warrantyType;
  final DateTime startAt;
  final DateTime expireAt;
  final bool isActive;

  WarrantyModel({
    required this.id,
    required this.transactionId,
    required this.itemId,
    required this.buyerName,
    required this.productName,
    required this.serialNumber,
    required this.warrantyType,
    required this.startAt,
    required this.expireAt,
    required this.isActive,
  });

  factory WarrantyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WarrantyModel(
      id: doc.id,
      transactionId: data['transactionId'] ?? '',
      itemId: data['itemId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      productName: data['productName'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      warrantyType: data['warrantyType'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      expireAt: (data['expireAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
    );
  }

  bool get isExpired {
    return DateTime.now().isAfter(expireAt);
  }

  bool get isReallyActive {
    return isActive && !isExpired;
  }

  String get warrantyTypeLabel {
    switch (warrantyType.toLowerCase()) {
      case 'service':
      case 'jasa':
        return 'Garansi Servis Jasa';
      case 'sparepart':
        return 'Garansi Sparepart';
      case 'both':
      case 'jasa & sparepart':
        return 'Garansi Servis Jasa & Sparepart';
      default:
        return 'Garansi';
    }
  }
}
