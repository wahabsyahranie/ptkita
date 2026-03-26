enum Itembrand { firman, stanley, blackdecker, dewalt, nobrand }

extension ItembrandX on Itembrand {
  static Itembrand fromBrandName(String? value) {
    switch (value?.toLowerCase()) {
      case 'firman':
        return Itembrand.firman;
      case 'stanley':
        return Itembrand.stanley;
      case 'dewalt':
        return Itembrand.dewalt;
      case 'black+decker':
        return Itembrand.blackdecker;
      case 'no_brand':
        return Itembrand.nobrand;
      default:
        return Itembrand.nobrand;
    }
  }
}
