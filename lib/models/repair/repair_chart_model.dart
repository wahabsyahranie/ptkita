class RepairChartModel {
  final List<int> warranty;
  final List<int> nonWarranty;
  final List<int> total;

  RepairChartModel({
    required this.warranty,
    required this.nonWarranty,
    required this.total,
  });

  factory RepairChartModel.empty() {
    return RepairChartModel(
      warranty: List.filled(4, 0),
      nonWarranty: List.filled(4, 0),
      total: List.filled(4, 0),
    );
  }
}
