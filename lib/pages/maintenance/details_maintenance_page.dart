import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance_model.dart';
import 'package:flutter_kita/styles/colors.dart';

class DetailsMaintenancePage extends StatefulWidget {
  final Maintenance? maintenance;
  const DetailsMaintenancePage({super.key, required this.maintenance});

  @override
  State<DetailsMaintenancePage> createState() => _DetailsMaintenancePageState();
}

class _DetailsMaintenancePageState extends State<DetailsMaintenancePage> {
  Maintenance? _maintenance;
  bool _isSaving = false;

  /// ✅ STATE VISUAL SAJA (TIDAK KE FIRESTORE)
  List<bool> _taskChecked = [];

  @override
  void initState() {
    super.initState();
    _maintenance = widget.maintenance;

    final taskCount = _maintenance?.tasks.length ?? 0;
    _taskChecked = List<bool>.filled(taskCount, false);
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
      // 📅 tanggal perawatan dilakukan
      final now = Timestamp.now();

      // ➕ hitung next maintenance dari SEKARANG
      final nextMaintenance = Timestamp.fromDate(
        now.toDate().add(Duration(days: _maintenance!.intervalDays)),
      );

      await FirebaseFirestore.instance
          .collection('maintenance')
          .doc(_maintenance!.id)
          .update({
            'status': 'selesai',
            'lastMaintenanceAt': now, // ✅ hari ini
            'nextMaintenanceAt': nextMaintenance, // ✅ hari ini + interval
          });

      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final itemName = _maintenance?.itemName ?? '-';
    final lastMaintenance = _maintenance?.lastMaintenanceAt == null
        ? 'belum pernah'
        : _maintenance!.lastMaintenanceAt!.toDate().toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
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
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Selesaikan Perawatan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
          const SizedBox(height: 10),
          Image.asset('assets/icons/icon_kita.png'),
          const SizedBox(height: 15),
          Text(
            itemName,
            style: const TextStyle(
              color: MyColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Perawatan tiba!',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const Text(
            'Rawat barang ini sebelum rusak',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 15),
          Text(
            'Perawatan Terakhir: $lastMaintenance',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 15),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _maintenance?.tasks.length ?? 0,
            itemBuilder: (context, index) {
              if (_taskChecked.length != _maintenance!.tasks.length) {
                _taskChecked = List<bool>.filled(
                  _maintenance!.tasks.length,
                  false,
                );
              }

              final task = _maintenance!.tasks[index];
              final checked = _taskChecked[index];

              return InkWell(
                onTap: () => _toggleTask(index),
                child: checked
                    ? _completeCard(task, index)
                    : _pendingCard(task, index),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================
  // CARD
  // =========================
  Widget _completeCard(MaintenanceTask task, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.green, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _checkIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(task.title, 'Selesai', MyColors.green),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(color: MyColors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingCard(MaintenanceTask task, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.secondary, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _circleIndex(index + 1, MyColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(task.title, 'Tandai', MyColors.secondary),
                const SizedBox(height: 8),
                Text(task.description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // HELPER
  // =========================
  Widget _checkIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: MyColors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: MyColors.white),
    );
  }

  Widget _circleIndex(int index, Color color) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '$index',
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _titleRow(String title, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          status,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
