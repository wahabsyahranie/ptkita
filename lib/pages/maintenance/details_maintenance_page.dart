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
  final Maintenance? maintenance;
  const DetailsMaintenancePage({super.key, required this.maintenance});

  @override
  State<DetailsMaintenancePage> createState() => _DetailsMaintenancePageState();
}

class _DetailsMaintenancePageState extends State<DetailsMaintenancePage> {
  Maintenance? _maintenance;
  bool _isSaving = false;
  String? _itemImageUrl;
  bool _loadingItem = true;
  late final MaintenanceService _service;

  /// ✅ STATE VISUAL SAJA (TIDAK KE FIRESTORE)
  List<bool> _taskChecked = [];

  @override
  void initState() {
    super.initState();
    _maintenance = widget.maintenance;
    _service = MaintenanceService(FirestoreMaintenanceRepository());
    _taskChecked = List<bool>.filled(_maintenance?.tasks.length ?? 0, false);
    _loadItemImage();
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
  Future<void> _finishMaintenance() async {
    if (_maintenance == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _service.finishMaintenance(_maintenance!);

      if (!mounted) return;

      setState(() {
        _taskChecked = List<bool>.filled(_maintenance!.tasks.length, false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perawatan berhasil diselesaikan')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan perawatan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Ambil Gambar
  Future<void> _loadItemImage() async {
    if (_maintenance == null) return;

    try {
      final imageUrl = await _service.getItemImageUrl(_maintenance!.itemId);

      if (!mounted) return;

      setState(() {
        _itemImageUrl = imageUrl;
        _loadingItem = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingItem = false);
      }
    }
  }

  //FUNGSI REFRESH HALAMAN SETELAH EDIT
  Future<void> _refreshItem() async {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final itemName = _maintenance?.itemName ?? '-';
    final lastMaintenance = _service.formatLastMaintenance(_maintenance);

    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          //EDIT BUTTON
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditMaintenancePage(maintenance: _maintenance),
                ),
              );

              // jika halaman AddEdit return true → refresh
              if (result == true) {
                await _refreshItem();
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

          //DELETE BUTTON
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: MyColors.white,
                  title: const Text('Hapus Data?'),
                  content: const Text('Item akan dihapus permanen.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (result != true) return;

              await _service.deleteMaintenance(_maintenance!.id);

              if (!mounted) return;

              ScaffoldMessenger.of(
                this.context,
              ).showSnackBar(const SnackBar(content: Text('Item dihapus')));

              Navigator.of(this.context).pop();
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
          Expanded(child: _buildContent(itemName, lastMaintenance)),

          /// 🔥 TOMBOL MUNCUL JIKA SEMUA TASK CENTANG
          if (_allTasksCompleted)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _finishMaintenance,
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
  }

  // =========================
  // CONTENT
  // =========================
  Widget _buildContent(String itemName, String lastMaintenance) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MaintenanceDetailHeader(
            itemName: itemName,
            lastMaintenance: lastMaintenance,
            imageWidget: MaintenanceItemImage(
              imageUrl: _itemImageUrl,
              isLoading: _loadingItem,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _maintenance?.tasks.length ?? 0,
            itemBuilder: (context, index) {
              final task = _maintenance!.tasks[index];
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
