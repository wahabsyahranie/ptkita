import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String? id;
  final String? name;
  final String? sku;
  final int? stock;
  final int? price;
  final String? description;
  final String? type;
  final String? imageUrl;
  final String? merk;
  final String? locationCode;

  Item({
    this.id,
    this.name,
    this.sku,
    this.stock,
    this.price,
    this.description,
    this.type,
    this.imageUrl,
    this.merk,
    this.locationCode,
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
      sku: data?['sku'] as String?,
      stock: (data?['stock'] is int)
          ? data!['stock'] as int
          : (data?['stock'] is num ? (data!['stock'] as num).toInt() : null),
      price: (data?['price'] is int)
          ? data!['price'] as int
          : (data?['price'] is num ? (data!['price'] as num).toInt() : null),
      description: data?['description'] as String?,
      type: data?['type'] as String?,
      imageUrl: data?['imageUrl'] as String?,
      merk: data?['merk'] as String?,
      locationCode: data?['locationCode'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (stock != null) 'stock': stock,
      if (price != null) 'price': price,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (merk != null) 'merk': merk,
      if (locationCode != null) 'locationCode': locationCode,
    };
  }
}
