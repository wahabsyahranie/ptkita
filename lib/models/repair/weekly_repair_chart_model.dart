class WeeklyRepairChartModel {
  final List<int> warranty;
  final List<int> nonWarranty;
  final List<int> completed;

  WeeklyRepairChartModel({
    required this.warranty,
    required this.nonWarranty,
    required this.completed,
  });

  List<int> get total =>
      List.generate(warranty.length, (i) => warranty[i] + nonWarranty[i]);
}
