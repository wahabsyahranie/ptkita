import 'package:flutter_kita/core/enum/item_brand.dart';

// ignore: camel_case_types
class merkLogoMapper {
  static const _basePath = 'assets/brands/';

  static String getAssetPath(Itemmerk merk) {
    switch (merk) {
      case Itemmerk.firman:
        return '${_basePath}firman.png';
      case Itemmerk.stanley:
        return '${_basePath}stanley.png';
      case Itemmerk.dewalt:
        return '${_basePath}dewalt.png';
      case Itemmerk.blackdecker:
        return '${_basePath}blackdecker.png';
      case Itemmerk.unknown:
        return '${_basePath}placeholder.png';
    }
  }
}
