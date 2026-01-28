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
  bool isComplete = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _maintenance = widget.maintenance;
  }

  /// 🔄 Fetch ulang data terbaru dari Firestore
  Future<void> _toggleTask(MaintenanceTask task, int index) async {
    setState(() {
      _maintenance!.tasks[index] = task.copyWith(completed: !task.completed);
    });

    await FirebaseFirestore.instance
        .collection('maintenance')
        .doc(_maintenance!.id)
        .update({
          'tasks': _maintenance!.tasks
              .map(
                (e) => {
                  'id': e.id,
                  'title': e.title,
                  'description': e.description,
                  'completed': e.completed,
                },
              )
              .toList(),
        });
  }

  @override
  Widget build(BuildContext context) {
    final itemName = _maintenance?.itemName ?? '-';
    final lastMaintenance = _maintenance?.lastMaintenanceAt == null
        ? 'belum pernah'
        : _maintenance!.lastMaintenanceAt!.toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // title: const Text('Detail Perawatan'),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        actionsPadding: EdgeInsets.only(right: 15),
        actions: [
          // DELETE BUTTON
          IconButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Hapus item?'),
                  content: const Text('Item akan dihapus permanen.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
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

              if (ok == true && _maintenance?.id != null) {
                //Hapus dokumen dari Firestore
                await FirebaseFirestore.instance
                    .collection('maintenance')
                    .doc(_maintenance!.id)
                    .delete();

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Item dihapus')));
                  Navigator.of(context).pop();
                }
              }
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
          _buildContent(itemName, lastMaintenance),

          if (_loading)
            Container(
              color: Colors.white.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: MyColors.secondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(String itemName, String lastMaintenance) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Image.asset('assets/icons/icon_kita.png'),
          const SizedBox(height: 15),
          Text(
            itemName,
            style: TextStyle(
              color: MyColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Perawatan tiba!',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          Text(
            'Rawat barang ini sebelum rusak',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 15),
          Text(
            'Perawatan Terakhir: $lastMaintenance',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _maintenance?.tasks.length ?? 0,
            itemBuilder: (context, index) {
              final task = _maintenance!.tasks[index];

              return InkWell(
                onTap: () => _toggleTask(task, index),
                child: task.completed
                    ? _completeCard(task, index)
                    : _pendingCard(task, index),
              );
            },
          ),
          // InkWell(
          //   onTap: () {
          //     setState(() {
          //       isComplete = !isComplete; // toggle
          //     });
          //   },
          //   child: isComplete ? _completeCard() : _pendingCard(),
          // ),
        ],
      ),
    );
  }

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
