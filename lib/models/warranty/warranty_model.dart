import 'package:cloud_firestore/cloud_firestore.dart';

class WarrantyModel {
  final String? id;
  final String buyerName;
  final String phone;
  final String productName;
  final String serialNumber;
  final String itemId;
  final String transactionId;
  final String warrantyType;
  final String brandName;

  final DateTime startAt;
  final DateTime expireAt;

  final int claimCount;
  final int? maxClaim;
  final String status;

  final DateTime createdAt;

  WarrantyModel({
    this.id,
    required this.buyerName,
    required this.phone,
    required this.productName,
    required this.serialNumber,
    required this.itemId,
    required this.transactionId,
    required this.warrantyType,
    required this.startAt,
    required this.expireAt,
    required this.claimCount,
    required this.status,
    required this.createdAt,
    required this.brandName,
    this.maxClaim,
  });

  factory WarrantyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WarrantyModel(
      id: doc.id,
      buyerName: data['buyerName'] ?? '',
      phone: data['phone'] ?? '',
      productName: data['productName'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      itemId: data['itemId'] ?? '',
      transactionId: data['transactionId'] ?? '',
      warrantyType: data['warrantyType'] ?? '',
      startAt: (data['startAt'] as Timestamp).toDate(),
      expireAt: (data['expireAt'] as Timestamp).toDate(),
      claimCount: data['claimCount'] ?? 0,
      status: data['status'] ?? 'Active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      brandName: data['brandName'] ?? data['brand'] ?? '',
      maxClaim: data['maxClaim'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerName': buyerName,
      'phone': phone,
      'productName': productName,
      'serialNumber': serialNumber,
      'itemId': itemId,
      'transactionId': transactionId,
      'warrantyType': warrantyType,
      'startAt': startAt,
      'expireAt': expireAt,
      'claimCount': claimCount,
      'brandName': brandName,
      'maxClaim': maxClaim,
      'status': status,
      'createdAt': createdAt,
    };
  }

  /// Helpers

  bool get isExpired => DateTime.now().isAfter(expireAt);

  bool get isActive => !isExpired;

  int get remainingDays => expireAt.difference(DateTime.now()).inDays;

  bool get isUnlimitedClaim => maxClaim == null;

  String get warrantyTypeLabel {
    switch (warrantyType.toLowerCase()) {
      case 'jasa':
        return 'Garansi Servis Jasa';

      case 'sparepart':
        return 'Garansi Sparepart';

      case 'jasa & sparepart':
        return 'Garansi Servis & Sparepart';

      default:
        return warrantyType;
    }
  }
}
