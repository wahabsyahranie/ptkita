import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/add_edit_maintenance_page.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_task_card.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_detail_header.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_item_image.dart';

class DetailsMaintenancePage extends StatefulWidget {
  final String maintenanceId;
  const DetailsMaintenancePage({super.key, required this.maintenanceId});

  @override
  State<DetailsMaintenancePage> createState() => _DetailsMaintenancePageState();
}

class _DetailsMaintenancePageState extends State<DetailsMaintenancePage> {
  bool _isSaving = false;
  late final MaintenanceService _service;

  /// ✅ STATE VISUAL SAJA (TIDAK KE FIRESTORE)
  List<bool> _taskChecked = [];

  @override
  void initState() {
    super.initState();
    _service = MaintenanceService(FirestoreMaintenanceRepository());
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

  // =========================
  // SELESAIKAN PERAWATAN
  // =========================
  Future<void> _finishMaintenance(Maintenance maintenance) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _service.finishMaintenance(maintenance);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perawatan berhasil diselesaikan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan perawatan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MaintenanceDetail?>(
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
        final imageUrl = detail.imageUrl;

        final itemName = maintenance.itemName;
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
                onPressed: () async {
                  await _service.deleteMaintenance(maintenance.id);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
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
              Expanded(
                child: _buildContent(
                  maintenance,
                  itemName,
                  lastMaintenance,
                  imageUrl,
                ),
              ),

              if (_allTasksCompleted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _finishMaintenance(maintenance),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.secondary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: MyColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
  Widget _buildContent(
    Maintenance maintenance,
    String itemName,
    String lastMaintenance,
    String? imageUrl,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MaintenanceDetailHeader(
            itemName: itemName,
            lastMaintenance: lastMaintenance,
            imageWidget: MaintenanceItemImage(
              imageUrl: imageUrl,
              isLoading: false,
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
