import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/brand/brand_model.dart';
import 'brand_repository.dart';

class FirestoreBrandRepository implements BrandRepository {
  final FirebaseFirestore _firestore;

  FirestoreBrandRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Brand> get _collection => _firestore
      .collection('brands')
      .withConverter<Brand>(
        fromFirestore: Brand.fromFirestore,
        toFirestore: (brand, _) => brand.toFirestore(),
      );

  @override
  Stream<List<Brand>> streamActiveBrands() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.data()).toList());
  }

  @override
  Future<void> addBrand(Brand brand) async {
    await _collection.add(brand);
  }

  @override
  Future<void> updateBrand(Brand brand) async {
    await _collection.doc(brand.id).set(brand, SetOptions(merge: true));
  }
}
