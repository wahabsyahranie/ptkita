// lib/models/maintenance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance {
  final String? id;
  final String itemId; // relasi ke items.id (opsional)
  final String itemName; // nama item (bisa copy dari Item)
  final String? sku;
  final Timestamp? nextMaintenanceAt; // Firestore timestamp
  final Timestamp? lastMaintenanceAt;
  final int? intervalDays;
  final String? priority; // "tinggi"/"sedang"/"rendah"
  final String? status; // "terjadwal","terlambat","selesai", dll
  final String? title;
  final String? description;

  Maintenance({
    this.id,
    required this.itemId,
    required this.itemName,
    this.sku,
    this.nextMaintenanceAt,
    this.lastMaintenanceAt,
    required this.intervalDays,
    required this.priority,
    required this.status,
    this.title,
    this.description,
  });

  factory Maintenance.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? opts,
  ) {
    final data = doc.data() ?? {};
    // itemId mungkin tersimpan sebagai String atau DocumentReference
    final rawItemId = data['itemId'];
    String itemIdStr;
    if (rawItemId == null) {
      itemIdStr = ''; // fallback
    } else if (rawItemId is String) {
      itemIdStr = rawItemId;
    } else if (rawItemId is DocumentReference) {
      // ambil document id (mis. '4hYPUqP...')
      itemIdStr = rawItemId.id;
    } else {
      // jika diserialisasi beda, coba toString()
      itemIdStr = rawItemId.toString();
    }

    return Maintenance(
      id: doc.id,
      itemId: itemIdStr,
      itemName: data['itemName'] as String? ?? '',
      sku: data['sku'] as String?,
      nextMaintenanceAt: data['nextMaintenanceAt'] as Timestamp?,
      lastMaintenanceAt: data['lastMaintenanceAt'] as Timestamp?,
      intervalDays: (data['intervalDays'] as num?)?.toInt() ?? 0,
      priority: data['priority'] as String? ?? 'rendah',
      status: data['status'] as String? ?? 'pending',
      title: data['title'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'name': itemName,
      'sku': sku,
      'nextMaintenanceAt': nextMaintenanceAt,
      'lastMaintenanceAt': lastMaintenanceAt,
      'intervalDays': intervalDays,
      'priority': priority,
      'status': status,
      'title': title,
      'description': description,
    };
  }
}
