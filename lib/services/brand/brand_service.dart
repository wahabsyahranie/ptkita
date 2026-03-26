import 'package:flutter/material.dart';
import 'package:flutter_kita/models/brand/brand_model.dart';
import 'package:flutter_kita/repositories/brand/brand_repository.dart';

class BrandService extends ChangeNotifier {
  final BrandRepository _repository;

  BrandService(this._repository);

  Stream<List<Brand>> streamActiveBrands() {
    return _repository.streamActiveBrands();
  }

  Future<void> createBrand(String name) async {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      throw Exception("Nama brand tidak boleh kosong");
    }

    final brand = Brand(
      id: '', // akan di-generate Firestore
      name: trimmed,
      isActive: true,
      isSystem: false,
      createdAt: DateTime.now(),
    );

    await _repository.addBrand(brand);
  }

  Future<void> deactivateBrand(Brand brand) async {
    if (brand.isSystem) {
      throw Exception("Brand sistem tidak bisa dinonaktifkan");
    }

    final updated = Brand(
      id: brand.id,
      name: brand.name,
      isActive: false,
      isSystem: brand.isSystem,
      createdAt: brand.createdAt,
    );

    await _repository.updateBrand(updated);
  }
}
