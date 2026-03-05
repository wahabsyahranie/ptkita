import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/warranty/warranty_model.dart';

class WarrantyService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addWarranty(WarrantyModel warranty) async {
    await _firestore.collection('warranty').add(warranty.toMap());
  }
}
