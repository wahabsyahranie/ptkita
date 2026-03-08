class InvertedIndex {
  final Map<String, Set<String>> _index = {};

  /// bersihkan index
  void clear() {
    _index.clear();
  }

  /// tambah dokumen ke index
  void addDocument(String id, List<String> fields) {
    for (final field in fields) {
      final tokens = _tokenize(field);

      for (final token in tokens) {
        _index.putIfAbsent(token, () => <String>{});
        _index[token]!.add(id);
      }
    }
  }

  /// search
  Set<String> search(String query) {
    final tokens = _tokenize(query);

    final Set<String> results = {};

    for (final token in tokens) {
      if (_index.containsKey(token)) {
        results.addAll(_index[token]!);
      }
    }

    return results;
  }

  /// tokenize text
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
