class InvertedIndex {
  final Map<String, Set<String>> _index = {};

  final Set<String> _stopwords = {
    "dan",
    "yang",
    "di",
    "ke",
    "dari",
    "the",
    "of",
    "a",
  };

  /// NORMALIZE TEXT
  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').trim();
  }

  /// TOKENIZE TEXT
  List<String> _tokenize(String text) {
    final words = _normalize(text).split(RegExp(r'\s+'));

    return words.where((w) => !_stopwords.contains(w) && w.isNotEmpty).toList();
  }

  /// ADD DOCUMENT TO INDEX (incremental)
  void addDocument(String id, List<String> fields) {
    for (final field in fields) {
      final tokens = _tokenize(field);

      for (final token in tokens) {
        _index.putIfAbsent(token, () => {});
        _index[token]!.add(id);
      }
    }
  }

  /// SEARCH
  Set<String> search(String query) {
    final tokens = _tokenize(query);

    Set<String>? result;

    for (final token in tokens) {
      final ids = _index[token];

      if (ids == null) continue;

      if (result == null) {
        result = Set.from(ids);
      } else {
        result = result.intersection(ids);
      }
    }

    return result ?? {};
  }

  void clear() {
    _index.clear();
  }
}
