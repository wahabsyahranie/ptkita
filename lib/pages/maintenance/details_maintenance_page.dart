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
    _service = MaintenanceService(
      FirestoreMaintenanceRepository(),
      InventoryService(
        FirestoreInventoryRepository(),
        UserService(FirestoreUserRepository()),
      ),
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
        final imageProvider = detail.imageProvider;
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
              Expanded(
                child: _buildContent(
                  maintenance,
                  itemName,
                  lastMaintenance,
                  imageProvider,
                ),
              ),

              if (_allTasksCompleted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _showFinishSheet(maintenance),
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
    ImageProvider imageProvider,
  ) {
    final initial = maintenance.cycleInitialQuantity;
    final remaining = maintenance.remainingQuantity;
    final completed = initial - remaining;

    final progress = initial > 0 ? (completed / initial).clamp(0.0, 1.0) : 0.0;
    return SingleChildScrollView(
      child: Column(
        children: [
          MaintenanceDetailHeader(
            itemName: itemName,
            lastMaintenance: lastMaintenance,
            imageWidget: MaintenanceItemImage(
              imageProvider: imageProvider,
              isLoading: false,
            ),
          ),
          if (maintenance.cycleInitialQuantity > 0)
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
                    value: progress,
                    minHeight: 8,
                    backgroundColor: MyColors.greySoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1 ? MyColors.success : MyColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$completed / $initial unit selesai "
                    "(${(progress * 100).toStringAsFixed(0)}%)",
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

  Future<void> _showFinishSheet(Maintenance maintenance) async {
    final parentContext = context; // simpan context parent
    final controller = TextEditingController(text: '1');
    final remaining = maintenance.remainingQuantity;

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: MyColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        String? localError;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selesaikan Maintenance",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text("Sisa saat ini: $remaining unit"),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Jumlah diselesaikan",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  if (localError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      localError!,
                      style: const TextStyle(color: MyColors.error),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.secondary.withValues(
                          alpha: 1,
                        ),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (_isSaving) return;
                              final value = int.tryParse(controller.text);

                              if (value == null || value <= 0) {
                                setModalState(() {
                                  localError = "Jumlah tidak valid";
                                });
                                return;
                              }

                              if (value > remaining) {
                                setModalState(() {
                                  localError = "Tidak boleh melebihi sisa";
                                });
                                return;
                              }

                              try {
                                setState(() {
                                  _isSaving = true;
                                });
                                final isCycleFinished = await _service
                                    .finishMaintenance(
                                      maintenance: maintenance,
                                      completedQuantity: value,
                                    );

                                if (!mounted) return;

                                Navigator.pop(sheetContext);

                                if (isCycleFinished) {
                                  Navigator.pop(parentContext);

                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Siklus selesai. Maintenance dijadwalkan ulang.',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Progress diperbarui.'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() {
                                  localError = e.toString();
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              }
                            },
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: MyColors.white,
                              ),
                            )
                          : const Text(
                              "Selesaikan",
                              style: TextStyle(color: MyColors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
