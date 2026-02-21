import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';

abstract class MaintenanceRepository {
  Stream<List<Maintenance>> streamMaintenance();

  Stream<List<Item>> streamItems();

  Future<void> save(Maintenance maintenance);

  Future<void> deleteMaintenance(String id);

  Future<void> finishMaintenance({
    required Maintenance maintenance,
    required DateTime completedAt,
  });

  Future<String?> getItemImageUrl(String itemId);

  Stream<MaintenanceDetail?> streamMaintenanceDetail(String id);
}
