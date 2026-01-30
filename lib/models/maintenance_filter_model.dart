class MaintenanceFilter {
  final Set<String> statuses; // terlambat, terjadwal, selesai
  final Set<String> priorities; // rendah, sedang, tinggi
  final Duration? timeRange; // 7d, 30d, 365d

  const MaintenanceFilter({
    this.statuses = const {},
    this.priorities = const {},
    this.timeRange,
  });
}
