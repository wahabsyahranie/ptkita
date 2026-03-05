import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/repair/repair_summary_model.dart';
import '../../models/repair/repair_chart_model.dart';
import 'home_repository.dart';

class FirestoreHomeRepository implements HomeRepository {
  final FirebaseFirestore _firestore;

  FirestoreHomeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==============================
  // ITEMS
  // ==============================

  @override
  Stream<int> getTotalItems() {
    return _firestore
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Stream<int> getOutOfStockItems() {
    return _firestore
        .collection('items')
        .where('stock', isEqualTo: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ==============================
  // MAINTENANCE TODAY
  // ==============================

  String _todayDocId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _todayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  @override
  Stream<int> getTotalMaintenanceToday() {
    return _firestore
        .collection('daily_maintenance_snapshot')
        .doc(_todayDocId())
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          final dueToday = doc.data()?['totalDueToday'] ?? 0;
          final overdue = doc.data()?['totalOverdue'] ?? 0;
          return dueToday + overdue;
        });
  }

  @override
  Stream<int> getCompletedMaintenanceToday() {
    return _firestore
        .collection('daily_maintenance_snapshot')
        .doc(_todayDocId())
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          return doc.data()?['completedToday'] ?? 0;
        });
  }

  // ==============================
  // REPAIR SUMMARY
  // ==============================

  @override
  Future<RepairSummaryModel> getRepairSummary(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final snapshot = await _firestore
        .collection('repair')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .get();

    int dalam = 0;
    int selesai = 0;

    for (var doc in snapshot.docs) {
      final status = doc['status'].toString().toLowerCase();

      if (status.contains('belum')) {
        dalam++;
      } else if (status.contains('selesai')) {
        selesai++;
      }
    }

    return RepairSummaryModel(
      dalamPerbaikan: dalam,
      selesai: selesai,
      total: snapshot.docs.length,
    );
  }

  // ==============================
  // WEEKLY CHART
  // ==============================

  @override
  Future<RepairChartModel> getChartData(String mode) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('repair')
        .get();

    List<int> warranty = [0, 0, 0, 0];
    List<int> nonWarranty = [0, 0, 0, 0];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? timestamp = data['date'];

      if (timestamp == null) continue;

      final DateTime date = timestamp.toDate();
      final bool isWarranty = data['repairCategory'] == 'warranty';

      int index = 0;

      if (mode == 'weekly') {
        final now = DateTime.now();
        final firstDay = DateTime(now.year, now.month, 1);
        final diff = date.difference(firstDay).inDays;
        if (diff < 0) continue;
        index = (diff ~/ 7).clamp(0, 3);
      } else {
        if (date.month <= 3) {
          index = 0;
        } else if (date.month <= 6) {
          index = 1;
        } else if (date.month <= 9) {
          index = 2;
        } else {
          index = 3;
        }
      }

      if (isWarranty) {
        warranty[index]++;
      } else {
        nonWarranty[index]++;
      }
    }

    List<int> total = List.generate(4, (i) => warranty[i] + nonWarranty[i]);

    return RepairChartModel(
      warranty: warranty,
      nonWarranty: nonWarranty,
      total: total,
    );
  }
}
