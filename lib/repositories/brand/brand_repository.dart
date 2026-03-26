import 'package:flutter_kita/models/brand/brand_model.dart';

abstract class BrandRepository {
  Stream<List<Brand>> streamActiveBrands();

  Future<void> addBrand(Brand brand);

  Future<void> updateBrand(Brand brand);
}
