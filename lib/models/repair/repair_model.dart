import 'package:cloud_firestore/cloud_firestore.dart';

class RepairModel {
  final String id;
  final String buyer;
  final String product;
  final String technician;
  final String status;
  final String repairType;
  final DateTime date;
  final Map<String, dynamic> raw;

  RepairModel({
    required this.id,
    required this.buyer,
    required this.product,
    required this.technician,
    required this.status,
    required this.repairType,
    required this.date,
    required this.raw,
  });

  factory RepairModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    /// parsing date
    DateTime parsedDate = DateTime.now();
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    }

    /// normalize string helper
    String parse(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return RepairModel(
      id: doc.id,

      /// mapping firestore → model
      buyer: parse(data['buyerName'] ?? data['buyer']),
      product: parse(data['itemName'] ?? data['product']),
      technician: parse(data['techName'] ?? data['technician']),
      status: parse(data['status']),
      repairType: parse(data['repairType']),

      date: parsedDate,
      raw: data,
    );
  }

  bool get isGaransi => repairType.toLowerCase().contains('garansi');

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
