import 'package:flutter_kita/core/enum/item_brand.dart';

// ignore: camel_case_types
class BrandLogoMapper {
  static const _basePath = 'assets/brands/';

  static String getAssetPath(Itembrand brand) {
    switch (brand) {
      case Itembrand.firman:
        return '${_basePath}firman.png';
      case Itembrand.stanley:
        return '${_basePath}stanley.png';
      case Itembrand.dewalt:
        return '${_basePath}dewalt.png';
      case Itembrand.blackdecker:
        return '${_basePath}blackdecker.png';
      case Itembrand.nobrand:
        return '${_basePath}placeholder.png';
    }
  }
}
