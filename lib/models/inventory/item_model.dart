import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String? id;
  final String? name;
  final String? typeUnit;
  final int? stock;
  final int? price;
  final String? description;
  final String? category;
  final String? imageUrl;
  final String? brandId;
  final String? brandName;
  final String? locationCode;
  final String? partNumber;
  final String? nameLowercase;
  final int movementBaseScore;
  final int movementAutoScore;
  final int movementTotalScore;
  final String? createdById;
  final String? createdByName;
  final DateTime? createdAt;
  final String? lastEditedById;
  final String? lastEditedByName;
  final DateTime? lastEditedAt;

  Item({
    this.id,
    this.name,
    this.typeUnit,
    this.stock,
    this.price,
    this.description,
    this.category,
    this.imageUrl,
    this.brandId,
    this.brandName,
    this.locationCode,
    this.nameLowercase,
    this.movementBaseScore = 0,
    this.movementAutoScore = 0,
    this.movementTotalScore = 0,
    this.partNumber,
    this.createdById,
    this.createdByName,
    this.createdAt,
    this.lastEditedById,
    this.lastEditedByName,
    this.lastEditedAt,
  });

  // factory sesuai contoh FlutterFire docs
  factory Item.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Item(
      id: snapshot.id,
      name: data?['name'] as String?,
      typeUnit: data?['typeUnit'] as String?,
      stock: (data?['stock'] is int)
          ? data!['stock'] as int
          : (data?['stock'] is num ? (data!['stock'] as num).toInt() : null),
      price: (data?['price'] is int)
          ? data!['price'] as int
          : (data?['price'] is num ? (data!['price'] as num).toInt() : null),
      description: data?['description'] as String?,
      category: data?['category'] as String?,
      imageUrl: data?['imageUrl'] as String?,
      brandId: data?['brandId'] as String?,
      brandName: data?['brandName'] as String?,
      locationCode: data?['locationCode'] as String?,
      nameLowercase: data?['name_lowercase'] as String?,
      movementBaseScore: (data?['movementBaseScore'] ?? 0) as int,
      movementAutoScore: (data?['movementAutoScore'] ?? 0) as int,
      movementTotalScore: (data?['movementTotalScore'] ?? 0) as int,
      partNumber: data?['partNumber'] as String?,
      createdById: data?['createdById'] as String?,
      createdByName: data?['createdByName'] as String?,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
      lastEditedById: data?['lastEditedById'] as String?,
      lastEditedByName: data?['lastEditedByName'] as String?,
      lastEditedAt: (data?['lastEditedAt'] as Timestamp?)?.toDate(),
    );
  }

  String? get brand => null;

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (typeUnit != null) 'typeUnit': typeUnit,
      if (stock != null) 'stock': stock,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (brandId != null) 'brandId': brandId,
      if (brandName != null) 'brandName': brandName,
      if (locationCode != null) 'locationCode': locationCode,
      if (nameLowercase != null) 'name_lowercase': nameLowercase,
      'movementBaseScore': movementBaseScore,
      'movementAutoScore': movementAutoScore,
      'movementTotalScore': movementTotalScore,
      if (partNumber != null) 'partNumber': partNumber,
      if (createdById != null) 'createdById': createdById,
      if (createdByName != null) 'createdByName': createdByName,
      if (createdAt != null) 'createdAt': createdAt,
      if (lastEditedById != null) 'lastEditedById': lastEditedById,
      if (lastEditedByName != null) 'lastEditedByName': lastEditedByName,
      if (lastEditedAt != null) 'lastEditedAt': lastEditedAt,
    };
  }

  Item copyWith({
    String? id,
    String? name,
    String? typeUnit,
    int? price,
    int? stock,
    String? description,
    String? locationCode,
    String? partNumber,
    String? category,
    String? merk,
    String? brandId,
    String? brandName,
    String? imageUrl,
    String? nameLowercase,
    int? movementBaseScore,
    int? movementAutoScore,
    int? movementTotalScore,
    String? createdById,
    String? createdByName,
    DateTime? createdAt,
    String? lastEditedById,
    String? lastEditedByName,
    DateTime? lastEditedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      typeUnit: typeUnit ?? this.typeUnit,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      locationCode: locationCode ?? this.locationCode,
      category: category ?? this.category,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      imageUrl: imageUrl ?? this.imageUrl,
      nameLowercase: nameLowercase ?? this.nameLowercase,
      movementBaseScore: movementBaseScore ?? this.movementBaseScore,
      movementAutoScore: movementAutoScore ?? this.movementAutoScore,
      movementTotalScore: movementTotalScore ?? this.movementTotalScore,
      partNumber: partNumber ?? this.partNumber,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      lastEditedById: lastEditedById ?? this.lastEditedById,
      lastEditedByName: lastEditedByName ?? this.lastEditedByName,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
    );
  }
}
