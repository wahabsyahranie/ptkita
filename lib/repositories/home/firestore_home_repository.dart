import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/repair/repair_summary_model.dart';
import '../../../models/repair/weekly_repair_chart_model.dart';
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
    final start = Timestamp.fromDate(_todayStart());
    final end = Timestamp.fromDate(_todayEnd());

    return _firestore
        .collection('maintenance_logs')
        .where('completedAt', isGreaterThanOrEqualTo: start)
        .where('completedAt', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
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
  Future<WeeklyRepairChartModel> getWeeklyRepairData() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _firestore
        .collection('repair')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .get();

    List<int> warranty = [0, 0, 0, 0];
    List<int> nonWarranty = [0, 0, 0, 0];
    List<int> completed = [0, 0, 0, 0];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final category = data['repairCategory'];
      final status = data['status'].toString().toLowerCase();

      int weekIndex = ((createdAt.day - 1) ~/ 7);
      if (weekIndex > 3) weekIndex = 3;

      if (category == 'warranty') {
        warranty[weekIndex]++;
      }

      if (category == 'non_warranty') {
        nonWarranty[weekIndex]++;
      }

      if (status.contains('selesai')) {
        completed[weekIndex]++;
      }
    }

    return WeeklyRepairChartModel(
      warranty: warranty,
      nonWarranty: nonWarranty,
      completed: completed,
    );
  }
}
