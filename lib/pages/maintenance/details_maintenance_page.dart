import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/confirmation_sheet.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/add_edit_maintenance_page.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/repositories/user/firestore_user_repository.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/services/user/user_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_task_card.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_detail_header.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_item_image.dart';
import 'package:flutter_kita/pages/maintenance/widgets/finish_maintenance_sheet.dart';

class DetailsMaintenancePage extends StatefulWidget {
  final String maintenanceId;
  const DetailsMaintenancePage({super.key, required this.maintenanceId});

  @override
  State<DetailsMaintenancePage> createState() => _DetailsMaintenancePageState();
}

class _DetailsMaintenancePageState extends State<DetailsMaintenancePage> {
  late final MaintenanceService _service;

  /// ✅ STATE VISUAL SAJA (TIDAK KE FIRESTORE)
  List<bool> _taskChecked = [];

  @override
  void initState() {
    super.initState();
    final userService = UserService(FirestoreUserRepository());

    _service = MaintenanceService(
      FirestoreMaintenanceRepository(),
      InventoryService(FirestoreInventoryRepository(), userService),
      userService,
    );
  }

  // =========================
  // TOGGLE TASK (UI ONLY)
  // =========================
  void _toggleTask(int index) {
    setState(() {
      _taskChecked[index] = !_taskChecked[index];
    });
  }

  // =========================
  // CEK SEMUA TASK SELESAI
  // =========================
  bool get _allTasksCompleted {
    if (_taskChecked.isEmpty) return false;
    return _taskChecked.every((v) => v);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MaintenanceDetailView?>(
      stream: _service.streamMaintenanceDetail(widget.maintenanceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: MyColors.white,
            body: Center(
              child: CircularProgressIndicator(color: MyColors.secondary),
            ),
          );
        }

        final detail = snapshot.data!;
        final maintenance = detail.maintenance;
        final lastMaintenance = _service.formatLastMaintenance(maintenance);

        if (_taskChecked.length != maintenance.tasks.length) {
          _taskChecked = List<bool>.filled(maintenance.tasks.length, false);
        }

        return Scaffold(
          backgroundColor: MyColors.white,
          appBar: AppBar(
            backgroundColor: MyColors.white,
            surfaceTintColor: Colors.transparent,
            actions: [
              // EDIT
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditMaintenancePage(maintenance: maintenance),
                    ),
                  );

                  if (result == true && mounted) {
                    setState(() {});
                  }
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: MyColors.secondary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.edit, color: MyColors.white),
                ),
              ),

              // DELETE
              IconButton(
                padding: const EdgeInsets.only(right: 20),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: MyColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => ConfirmationSheet(
                      title: "Hapus perawatan?",
                      description: "Data perawatan akan dihapus permanen.",
                      confirmText: "Hapus",
                      isDestructive: true,
                      onConfirm: () async {
                        await _service.deleteById(maintenance.id);

                        if (!context.mounted) return;

                        Navigator.pop(context); // tutup sheet
                      },
                    ),
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: MyColors.secondary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.delete, color: MyColors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _buildContent(detail, lastMaintenance)),

              if (_allTasksCompleted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: MyColors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => FinishMaintenanceSheet(
                          maintenance: maintenance,
                          service: _service,
                        ),
                      );

                      if (!mounted) return;

                      if (result == true) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Siklus selesai. Maintenance dijadwalkan ulang.',
                            ),
                          ),
                        );
                      } else if (result == false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Progress diperbarui.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.secondary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'Selesaikan Perawatan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // CONTENT
  // =========================
  Widget _buildContent(MaintenanceDetailView detail, String lastMaintenance) {
    final maintenance = detail.maintenance;
    return SingleChildScrollView(
      child: Column(
        children: [
          MaintenanceDetailHeader(
            itemName: maintenance.itemName,
            lastMaintenance: lastMaintenance,
            imageWidget: MaintenanceItemImage(
              imageProvider: detail.imageProvider,
              isLoading: false,
            ),
          ),
          if (detail.initialQuantity > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Progress Pengerjaan",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: detail.progress,
                    minHeight: 8,
                    backgroundColor: MyColors.greySoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      detail.progress == 1
                          ? MyColors.success
                          : MyColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${detail.completedQuantity} / ${detail.initialQuantity} unit selesai "
                    "(${(detail.progress * 100).toStringAsFixed(0)}%)",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: maintenance.tasks.length,
            itemBuilder: (context, index) {
              final task = maintenance.tasks[index];
              final checked = _taskChecked[index];

              return MaintenanceTaskCard(
                task: task,
                checked: checked,
                index: index,
                onTap: () => _toggleTask(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
