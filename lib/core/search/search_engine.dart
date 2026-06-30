class InvertedIndex {
  final Map<String, Set<String>> _index = {};

  /// bersihkan index
  void clear() {
    _index.clear();
  }

  /// Menambahkan dokumen ke dalam struktur Inverted Index
  void addDocument(String id, List<String> fields) {
    for (final field in fields) {
      // print("FIELD: $field");
      // print("TOKENS: ${_tokenize(field)}");
      final tokens = _tokenize(field);

      for (final token in tokens) {
        _index.putIfAbsent(token, () => <String>{});
        _index[token]!.add(id);
      }
    }
    // print("INDEX SAAT INI:");
    // print(_index);
  }

  /// Mencocokkan kata kunci pencarian dengan token pada Inverted Index
  Set<String> search(String query) {
    final tokens = _tokenize(query);

    final Set<String> results = {};

    for (final token in tokens) {
      for (final key in _index.keys) {
        if (key.startsWith(token)) {
          // print("MATCH: $key");
          results.addAll(_index[key]!);
        }
      }
    }

    return results;
  }

  /// Melakukan tokenisasi dan normalisasi teks
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
