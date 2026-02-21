import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'maintenance_repository.dart';

class FirestoreMaintenanceRepository implements MaintenanceRepository {
  final FirebaseFirestore _firestore;

  FirestoreMaintenanceRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Maintenance>> streamMaintenance() {
    return _firestore
        .collection('maintenance')
        .orderBy('nextMaintenanceAt')
        .withConverter<Maintenance>(
          fromFirestore: Maintenance.fromFirestore,
          toFirestore: (Maintenance m, _) => m.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => e.data()).toList());
  }

  @override
  Future<void> addMaintenance(Map<String, dynamic> payload) async {
    await _firestore.collection('maintenance').add({
      ...payload,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateMaintenance(
    String id,
    Map<String, dynamic> payload,
  ) async {
    await _firestore.collection('maintenance').doc(id).update({
      ...payload,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteMaintenance(String id) async {
    await _firestore.collection('maintenance').doc(id).delete();
  }

  @override
  Future<void> finishMaintenance({
    required Maintenance maintenance,
    required DateTime completedAt,
  }) async {
    final batch = _firestore.batch();

    final maintenanceRef = _firestore
        .collection('maintenance')
        .doc(maintenance.id);

    final logRef = _firestore.collection('maintenance_logs').doc();

    final completedTimestamp = Timestamp.fromDate(completedAt);

    final nextMaintenance = Timestamp.fromDate(
      completedAt.add(Duration(days: maintenance.intervalDays)),
    );

    // 1️⃣ write log
    batch.set(logRef, {
      'maintenanceId': maintenance.id,
      'completedAt': completedTimestamp,
      'itemId': maintenance.itemId,
    });

    // 2️⃣ update maintenance
    batch.update(maintenanceRef, {
      'lastMaintenanceAt': completedTimestamp,
      'nextMaintenanceAt': nextMaintenance,
    });

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

  @override
  Stream<List<Map<String, dynamic>>> streamItems() {
    return _firestore
        .collection('items')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, 'name': data['name'], 'sku': data['sku']};
          }).toList(),
        );
  }
}
