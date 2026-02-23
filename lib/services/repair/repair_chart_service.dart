import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/models/repair/repair_chart_model.dart';

class RepairChartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<RepairChartModel> getChartData(String mode) async {
    final snapshot = await _firestore.collection('repair').get();

    final model = RepairChartModel.empty();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? timestamp = data['date'];

      if (timestamp == null) continue;

      final DateTime date = timestamp.toDate();
      final bool isWarranty = data['repairCategory'] == 'warranty';

      int index = 0;

      if (mode == 'weekly') {
        index = _getWeekIndex(date);
      } else if (mode == 'quarterly') {
        index = _getQuarterIndex(date);
      }

      if (index < 0 || index > 3) continue;

      if (isWarranty) {
        model.warranty[index]++;
      } else {
        model.nonWarranty[index]++;
      }

      model.total[index]++;
    }

    return model;
  }

  int _getWeekIndex(DateTime date) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final difference = date.difference(firstDayOfMonth).inDays;

    if (difference < 0) return -1;

    return (difference ~/ 7).clamp(0, 3);
  }

  int _getQuarterIndex(DateTime date) {
    if (date.month <= 3) return 0;
    if (date.month <= 6) return 1;
    if (date.month <= 9) return 2;
    return 3;
  }
}
