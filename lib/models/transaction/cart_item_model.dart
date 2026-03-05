class CartItemModel {
  final String itemId;
  final String name;
  final int price;
  final int qty;

  final bool hasWarranty;
  final int warrantyYear;
  final String? warrantyType;

  final List<String> serialNumbers;

  CartItemModel({
    required this.itemId,
    required this.name,
    required this.price,
    required this.qty,
    required this.hasWarranty,
    required this.warrantyYear,
    required this.warrantyType,
    this.serialNumbers = const [],
  });

  int get subtotal => price * qty;

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'qty': qty,
      'subtotal': subtotal,
      'hasWarranty': hasWarranty,
      'warrantyYear': warrantyYear,
      'warrantyType': warrantyType,
      'serialNumbers': serialNumbers,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      itemId: map['itemId'],
      name: map['name'],
      price: map['price'],
      qty: map['qty'],
      hasWarranty: map['hasWarranty'] ?? false,
      warrantyYear: map['warrantyYear'] ?? 0,
      warrantyType: map['warrantyType'],
      serialNumbers: List<String>.from(map['serialNumbers'] ?? []),
    );
  }
}
