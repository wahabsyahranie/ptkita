import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String id;
  final String name;
  final bool isActive;
  final bool isSystem;
  final String? logoUrl;
  final DateTime? createdAt;

  Brand({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isSystem,
    this.logoUrl,
    this.createdAt,
  });

  factory Brand.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Brand(
      id: snapshot.id,
      name: data?['name'] as String? ?? '',
      isActive: data?['isActive'] as bool? ?? true,
      isSystem: data?['isSystem'] as bool? ?? false,
      logoUrl: data?['logoUrl'] as String?,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isActive': isActive,
      'isSystem': isSystem,
      if (createdAt != null) 'createdAt': createdAt,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }
}
