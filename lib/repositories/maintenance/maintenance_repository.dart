import 'package:flutter_kita/models/maintenance/maintenance_model.dart';

abstract class MaintenanceRepository {
  Stream<List<Maintenance>> streamMaintenance();

  Future<void> addMaintenance(Map<String, dynamic> payload);

  Future<void> updateMaintenance(String id, Map<String, dynamic> payload);

  Future<void> deleteMaintenance(String id);

  Future<void> finishMaintenance({
    required Maintenance maintenance,
    required DateTime completedAt,
  });

  Future<String?> getItemImageUrl(String itemId);
}
