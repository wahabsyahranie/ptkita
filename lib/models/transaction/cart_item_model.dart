class CartItemModel {
  final String itemId;
  final String name;
  final int price;
  final int qty;
  final String type;

  final bool hasWarranty;
  final int warrantyYear;
  final String? warrantyType;
  final int? claimLimit;
  final String? brandName;

  final List<String> serialNumbers;

  CartItemModel({
    required this.itemId,
    required this.name,
    required this.type,
    required this.price,
    required this.qty,
    required this.hasWarranty,
    required this.warrantyYear,
    required this.warrantyType,
    required this.serialNumbers,
    this.claimLimit,
    this.brandName,
  });

  /// digunakan untuk update sebagian field (misalnya tambah qty)
  CartItemModel copyWith({
    String? itemId,
    String? name,
    int? price,
    int? qty,
    String? type,
    bool? hasWarranty,
    int? warrantyYear,
    String? warrantyType,
    int? claimLimit,
    String? brandName,
    List<String>? serialNumbers,
  }) {
    return CartItemModel(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      type: type ?? this.type,
      hasWarranty: hasWarranty ?? this.hasWarranty,
      warrantyYear: warrantyYear ?? this.warrantyYear,
      warrantyType: warrantyType ?? this.warrantyType,
      claimLimit: claimLimit ?? this.claimLimit,
      brandName: brandName ?? this.brandName,
      serialNumbers: serialNumbers ?? this.serialNumbers,
    );
  }

  /// subtotal per item
  int get subtotal => price * qty;

  /// convert ke firestore map
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'type': type,
      'price': price,
      'qty': qty,
      'subtotal': subtotal,
      'hasWarranty': hasWarranty,
      'warrantyYear': warrantyYear,
      'warrantyType': warrantyType,
      'claimLimit': claimLimit,
      'brandName': brandName,
      'serialNumbers': serialNumbers,
    };
  }

  /// convert dari firestore map
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      itemId: map['itemId'],
      name: map['name'],
      price: map['price'],
      qty: map['qty'],
      type: map['type'],
      hasWarranty: map['hasWarranty'] ?? false,
      warrantyYear: map['warrantyYear'] ?? 0,
      warrantyType: map['warrantyType'],
      claimLimit: map['claimLimit'],
      serialNumbers: List<String>.from(map['serialNumbers'] ?? []),
    );
  }
}
