class MaintenanceReportSummary {
  const MaintenanceReportSummary({
    required this.total,
    required this.completed,
    required this.skipped,
    required this.quantity,
  });

  final int total;
  final int completed;
  final int skipped;
  final int quantity;
}
