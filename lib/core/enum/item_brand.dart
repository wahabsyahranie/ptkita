enum Itemmerk { firman, stanley, blackdecker, dewalt, unknown }

extension ItemmerkX on Itemmerk {
  static Itemmerk fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'firman':
        return Itemmerk.firman;
      case 'stanley':
        return Itemmerk.stanley;
      case 'dewalt':
        return Itemmerk.dewalt;
      case 'black+decker':
        return Itemmerk.blackdecker;
      default:
        return Itemmerk.unknown;
    }
  }
}
