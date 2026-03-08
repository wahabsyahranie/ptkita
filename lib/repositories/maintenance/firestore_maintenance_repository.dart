import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'maintenance_repository.dart';

class FirestoreMaintenanceRepository implements MaintenanceRepository {
  final FirebaseFirestore _firestore;
  CollectionReference<Maintenance> get _collection => _firestore
      .collection('maintenance')
      .withConverter<Maintenance>(
        fromFirestore: Maintenance.fromFirestore,
        toFirestore: (m, _) => m.toFirestore(),
      );

  @override
  Stream<MaintenanceDetail?> streamMaintenanceDetail(String id) {
    return _firestore
        .collection('maintenance')
        .doc(id)
        .withConverter<Maintenance>(
          fromFirestore: Maintenance.fromFirestore,
          toFirestore: (m, _) => m.toFirestore(),
        )
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) return null;

          final maintenance = doc.data()!;

          final itemSnap = await _firestore
              .collection('items')
              .doc(maintenance.itemId)
              .get();

          Item? item;

          if (itemSnap.exists) {
            item = Item.fromFirestore(itemSnap, null);
          }

          return MaintenanceDetail(maintenance: maintenance, item: item);
        });
  }

  FirestoreMaintenanceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Maintenance>> streamMaintenance() {
    return _firestore
        .collection('maintenance')
        .orderBy('nextMaintenanceAt')
        .limit(500)
        .withConverter<Maintenance>(
          fromFirestore: Maintenance.fromFirestore,
          toFirestore: (Maintenance m, _) => m.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.data()).toList());
  }

  @override
  Future<void> save(Maintenance maintenance) async {
    if (maintenance.id.isEmpty) {
      await _collection.add(maintenance);
    } else {
      await _collection
          .doc(maintenance.id)
          .set(maintenance, SetOptions(merge: true));
    }
  }

  @override
  Future<void> deleteMaintenance(String id) async {
    await _firestore.collection('maintenance').doc(id).delete();
  }

  @override
  Future<void> commitMaintenanceBatch({
    required String maintenanceId,
    required Map<String, dynamic> maintenanceUpdate,
    required Map<String, dynamic> logData,
    required bool incrementCompletedToday,
  }) async {
    final batch = _firestore.batch();

    final maintenanceRef = _firestore
        .collection('maintenance')
        .doc(maintenanceId);

    final logRef = _firestore.collection('maintenance_logs').doc();

    // 1️⃣ insert log
    batch.set(logRef, logData);

    // 2️⃣ update maintenance
    batch.update(maintenanceRef, maintenanceUpdate);

    // 3️⃣ update snapshot (hanya jika siklus selesai)
    if (incrementCompletedToday) {
      final now = DateTime.now();
      final docId =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final snapshotRef = _firestore
          .collection('daily_maintenance_snapshot')
          .doc(docId);

      batch.set(snapshotRef, {
        'completedToday': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<String?> getItemImageUrl(String itemId) async {
    if (itemId.isEmpty) return null;

    final ref = _firestore.collection('items').doc(itemId);
    final snap = await ref.get();

    final data = snap.data();
    return data?['imageUrl'] as String?;
  }

  CollectionReference<Item> get _itemCollection => _firestore
      .collection('items')
      .withConverter<Item>(
        fromFirestore: Item.fromFirestore,
        toFirestore: (i, _) => i.toFirestore(),
      );

  @override
  Stream<List<Item>> streamItems() {
    return _itemCollection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }
}
