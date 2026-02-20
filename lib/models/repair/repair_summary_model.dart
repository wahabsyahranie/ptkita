class RepairSummaryModel {
  final int dalamPerbaikan;
  final int selesai;
  final int total;

  RepairSummaryModel({
    required this.dalamPerbaikan,
    required this.selesai,
    required this.total,
  });

  double get dalamProgress => total == 0 ? 0 : dalamPerbaikan / total;

  double get selesaiProgress => total == 0 ? 0 : selesai / total;
}
