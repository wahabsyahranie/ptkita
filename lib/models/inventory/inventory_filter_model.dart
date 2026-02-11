class InventoryFilter {
  final String? availability; // null = semua
  final String? category; // null = semua
  final Set<String> brands; // empty = semua

  const InventoryFilter({
    this.availability,
    this.category,
    this.brands = const {},
  });

  InventoryFilter copyWith({
    String? availability,
    String? category,
    Set<String>? brands,
  }) {
    return InventoryFilter(
      availability: availability ?? this.availability,
      category: category ?? this.category,
      brands: brands ?? this.brands,
    );
  }
}
