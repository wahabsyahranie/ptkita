import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';

abstract class MaintenanceRepository {
  Stream<List<Maintenance>> streamMaintenance();

  Future<List<Item>> getTopItems({int limit = 4});

  Future<List<Item>> searchItems(String query, {int limit = 10});

  Future<void> save(Maintenance maintenance);

  Future<void> deleteMaintenance(String id);

  Future<void> commitMaintenanceBatch({
    required String maintenanceId,
    required Map<String, dynamic> maintenanceUpdate,
    required Map<String, dynamic> logData,
    required bool incrementCompletedToday,
  });

  Future<String?> getItemImageUrl(String itemId);

  Stream<MaintenanceDetail?> streamMaintenanceDetail(String id);

  Future<Maintenance?> getByItemId(String itemId);
}
