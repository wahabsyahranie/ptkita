import '../../../models/repair/repair_summary_model.dart';
import '../../models/repair/repair_chart_model.dart';

abstract class HomeRepository {
  Stream<int> getTotalItems();
  Stream<int> getOutOfStockItems();
  Stream<int> getTotalMaintenanceToday();
  Stream<int> getCompletedMaintenanceToday();

  Future<RepairSummaryModel> getRepairSummary(int days);
  Future<RepairChartModel> getChartData(String mode);
}
