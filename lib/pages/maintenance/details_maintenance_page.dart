import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/add_edit_maintenance_page.dart';
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
  String? _itemImageUrl;
  bool _loadingItem = true;

  /// ✅ STATE VISUAL SAJA (TIDAK KE FIRESTORE)
  List<bool> _taskChecked = [];

  @override
  void initState() {
    super.initState();
    _maintenance = widget.maintenance;

    // final taskCount = _maintenance?.tasks.length ?? 0;
    // _taskChecked = List<bool>.filled(taskCount, false);
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
      // 📅 tanggal perawatan dilakukan
      final now = Timestamp.now();

      // ➕ hitung next maintenance dari SEKARANG
      final nextMaintenance = Timestamp.fromDate(
        now.toDate().add(Duration(days: _maintenance!.intervalDays)),
      );

      final firestore = FirebaseFirestore.instance;

      // 1️⃣ TULIS LOG (INI YANG KURANG)
      await firestore.collection('maintenance_logs').add({
        'maintenanceId': _maintenance!.id,
        'completedAt': now,
        'itemId': _maintenance!.itemId, // opsional tapi sangat berguna
      });

      await FirebaseFirestore.instance
          .collection('maintenance')
          .doc(_maintenance!.id)
          .update({
            'lastMaintenanceAt': now, // ✅ hari ini
            'nextMaintenanceAt': nextMaintenance, // ✅ hari ini + interval
          });

      if (!mounted) return;

      // 🔥 RESET VISUAL CHECKLIST
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

  // Ambil Gambar dari items collections
  Future<void> _loadItemImage() async {
    if (_maintenance == null) return;

    try {
      final rawItemId = _maintenance!.itemId;

      if (rawItemId.isEmpty) return;

      // ✅ AMAN: handle path ATAU id
      final DocumentReference itemRef = rawItemId.contains('/')
          ? FirebaseFirestore.instance.doc(rawItemId)
          : FirebaseFirestore.instance.collection('items').doc(rawItemId);

      final snap = await itemRef.get();
      final data = snap.data() as Map<String, dynamic>?;

      if (!mounted) return;

      setState(() {
        _itemImageUrl = data?['imageUrl'] as String?;
        _loadingItem = false;
      });

      // 🔍 DEBUG (hapus setelah yakin)
      debugPrint('ITEM DOC: ${snap.id}');
      debugPrint('IMAGE URL: $_itemImageUrl');
    } catch (e) {
      debugPrint('LOAD IMAGE ERROR: $e');
      if (mounted) {
        setState(() => _loadingItem = false);
      }
    }
  }

  //FUNGSI REFRESH HALAMAN SETELAH EDIT
  Future<void> _refreshItem() async {
    if (_maintenance == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('maintenance')
          .doc(_maintenance!.id)
          .get();

      if (!snap.exists || !mounted) return;

      final fresh = Maintenance.fromFirestore(snap, null);

      setState(() {
        _maintenance = fresh;

        // 🔥 reset checklist visual
        _taskChecked = List<bool>.filled(fresh.tasks.length, false);

        // 🔥 reload image item (kalau itemId berubah)
        _loadingItem = true;
      });

      await _loadItemImage();
    } catch (e) {
      debugPrint('REFRESH ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemName = _maintenance?.itemName ?? '-';
    final lastMaintenance =
        _maintenance?.lastMaintenanceAt?.toDate().toString() ?? 'belum pernah';

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

              await FirebaseFirestore.instance
                  .collection('maintenance')
                  .doc(_maintenance!.id)
                  .delete();

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
          const SizedBox(height: 10),
          // Image.asset('assets/icons/icon_kita.png'),
          _buildItemImage(),
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
        border: Border.all(color: MyColors.success, width: 2),
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
                _titleRow(task.title, 'Selesai', MyColors.success),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(color: MyColors.success),
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
        color: MyColors.success,
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

  Widget _buildItemImage() {
    if (_loadingItem) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: MyColors.secondary),
        ),
      );
    }

    if (_itemImageUrl == null || _itemImageUrl!.isEmpty) {
      return const Icon(
        Icons.image_not_supported,
        size: 100,
        color: MyColors.greySoft,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        _itemImageUrl!,
        height: 140,
        width: 140,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.broken_image,
            size: 100,
            color: MyColors.greySoft,
          );
        },
      ),
    );
  }
}
