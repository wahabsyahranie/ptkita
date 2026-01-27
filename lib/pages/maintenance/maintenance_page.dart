import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/add_edit_maintenance_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  // search
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // debounce search
  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      _searchDebounce?.cancel();
      setState(() {
        _searchQuery = '';
      });
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.toLowerCase().trim();
      });
    });
  }

  Query<Maintenance> _buildQuery() {
    Query base = FirebaseFirestore.instance.collection('maintenance');

    base = base.orderBy('nextMaintenanceAt');

    return base.withConverter<Maintenance>(
      fromFirestore: Maintenance.fromFirestore,
      toFirestore: (Maintenance main, _) => main.toFirestore(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _buildQuery();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.25),
        title: const Text("Data Perawatan"),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    // searchBar
                    Expanded(
                      child: SearchBarWidget(
                        controller: _searchCtrl,
                        hintText: 'Cari nama atau SKU',
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // tombol add
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: MyColors.secondary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddEditMaintenancePage(),
                            ),
                          );
                          // if (!mounted) return;
                          // setState(() {
                          //   _appliedFilter = null;
                          //   _searchQuery = '';
                          //   _searchCtrl.clear();
                          //   itemsToShow = 6;
                          // });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // tombol filter
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: MyColors.secondary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        // onPressed: _openFilterSheet,
                        icon: const Icon(
                          Icons.filter_alt,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Maintenance>>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: MyColors.secondary),
              );
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('Belum ada perawatan.'));
            }

            final allIems = docs.map((d) => d.data()).toList();

            final filtered = _searchQuery.isEmpty
                ? allIems
                : allIems.where((main) {
                    final name = (main.name ?? '').toLowerCase();
                    final sku = (main.sku ?? '').toLowerCase();
                    return name.contains(_searchQuery) ||
                        sku.contains(_searchQuery);
                  }).toList();

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final main = filtered[idx];
                return _MaintenanceBox(main: main);
              },
            );
          },
        ),
      ),
    );
  }
}

class _MaintenanceBox extends StatelessWidget {
  final Maintenance main;

  const _MaintenanceBox({required this.main});

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '-';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'tinggi':
        return Colors.red.shade200;
      case 'sedang':
        return Colors.amber.shade200;
      default:
        return Colors.blue.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = main.name;
    final sku = main.sku ?? '-';
    final nextMaintenanceAt = _formatDate(main.nextMaintenanceAt);
    final intervalDays = main.intervalDays ?? 0;
    final priority = main.priority ?? 'rendah';
    final status = main.status ?? '-';

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + priority badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _priorityColor(priority),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priority[0].toUpperCase() + priority.substring(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 6),
            Text(sku, style: TextStyle(color: Colors.black.withOpacity(0.7))),
            const SizedBox(height: 12),

            // row icons date + interval + status
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(nextMaintenanceAt),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Setiap $intervalDays hari'),
                const Spacer(),
              ],
            ),
            // status badge
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'terlambat'
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
