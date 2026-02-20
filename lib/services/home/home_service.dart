import 'package:flutter_kita/repositories/home/home_repository.dart';
import 'package:flutter_kita/models/repair/repair_summary_model.dart';
import 'package:flutter_kita/models/repair/weekly_repair_chart_model.dart';

class HomeService {
  final HomeRepository repository;

  HomeService(this.repository);

  Stream<int> totalItems() => repository.getTotalItems();

  Stream<int> outOfStock() => repository.getOutOfStockItems();

  Stream<int> totalMaintenanceToday() => repository.getTotalMaintenanceToday();

  Stream<int> completedMaintenanceToday() =>
      repository.getCompletedMaintenanceToday();

  Future<RepairSummaryModel> repairSummary(int days) =>
      repository.getRepairSummary(days);

  Future<WeeklyRepairChartModel> weeklyRepairData() =>
      repository.getWeeklyRepairData();
}
