class RepairChartModel {
  final List<int> warranty;
  final List<int> nonWarranty;
  final List<int> total;

  RepairChartModel({
    required this.warranty,
    required this.nonWarranty,
    required this.total,
  });

  factory RepairChartModel.empty(int length) {
    return RepairChartModel(
      warranty: List.filled(length, 0),
      nonWarranty: List.filled(length, 0),
      total: List.filled(length, 0),
    );
  }
}
