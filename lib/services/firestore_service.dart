import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Item?> getItemByName(String name) async {
    final query = await _db
        .collection('items')
        .where('name_lowercase', isEqualTo: name.toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return Item.fromFirestore(query.docs.first, null);
  }
}
