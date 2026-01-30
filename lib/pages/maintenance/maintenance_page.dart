import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance_filter_model.dart';
import 'package:flutter_kita/models/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/add_edit_maintenance_page.dart';
import 'package:flutter_kita/pages/maintenance/details_maintenance_page.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_filter_sheet.dart';
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

  // =========================
  // FILTER STATE
  // =========================
  // Menyimpan filter yang sedang aktif di halaman Maintenance.
  // Filter ini TIDAK disimpan ke Firestore, hanya untuk kebutuhan UI (client-side).
  MaintenanceFilter? _appliedFilter;

  // =========================
  // DEFAULT FILTER (INIT STATE)
  // =========================
  // Default tampilan halaman Maintenance:
  // - Menampilkan perawatan yang:
  //   1. Status-nya TERLAMBAT atau TERJADWAL
  //   2. Waktu perawatan berikutnya dalam 7 hari ke depan
  //
  // Tujuan:
  // - Fokus ke perawatan yang perlu segera ditangani
  // - Fokus pada perawatan yang perlu ditangani (terlambat & terjadwal)

  @override
  void initState() {
    super.initState();
    _appliedFilter = MaintenanceFilter(
      statuses: {'terlambat', 'terjadwal'},
      timeRange: const Duration(days: 7),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // =========================
  // APPLY FILTER (CLIENT SIDE)
  // =========================
  // Fungsi ini bertugas menyaring daftar maintenance berdasarkan filter yang aktif.
  // Proses filtering dilakukan di sisi client karena:
  // - Jumlah data < 100
  // - Status bersifat turunan (derived state)
  // - Menghindari kompleksitas index Firestore

  List<Maintenance> applyFilter(
    List<Maintenance> items,
    MaintenanceFilter? filter,
  ) {
    // Jika tidak ada filter → tampilkan semua data
    if (filter == null) return items;

    final now = DateTime.now();

    return items.where((m) {
      final next = m.nextMaintenanceAt!.toDate();

      // =========================
      // FILTER STATUS
      // =========================
      // Status tidak hanya berdasarkan field 'status',
      // tetapi juga hasil perbandingan waktu.
      if (filter.statuses.isNotEmpty) {
        // TERLAMBAT:
        final isLate = next.isBefore(now);
        // TERJADWAL:
        final isScheduled = next.isAfter(now);

        // - Filter meminta "terlambat" DAN data terlambat
        // - Filter meminta "terjadwal" DAN data terjadwal
        // - Filter meminta "selesai" DAN status = selesai
        final statusMatch =
            (filter.statuses.contains('terlambat') && isLate) ||
            (filter.statuses.contains('terjadwal') && isScheduled);

        // Jika tidak cocok → buang data
        if (!statusMatch) return false;
      }

      // =========================
      // FILTER PRIORITY
      // =========================
      // Menyaring berdasarkan tingkat prioritas perawatan:
      // rendah | sedang | tinggi
      if (filter.priorities.isNotEmpty &&
          !filter.priorities.contains(m.priority)) {
        return false;
      }

      // =========================
      // FILTER RENTANG WAKTU
      // =========================
      if (filter.timeRange != null &&
          next.isAfter(now.add(filter.timeRange!))) {
        return false;
      }

      return true;
    }).toList();
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

  // =========================
  // OPEN FILTER SHEET
  // =========================
  // Menampilkan bottom sheet untuk memilih filter maintenance.
  // Filter lama dikirim sebagai initial value.
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<MaintenanceFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColors.white,
      useSafeArea: true,
      builder: (_) {
        return MaintenanceFilterSheet(initialFilter: _appliedFilter);
      },
    );

    if (result != null && mounted) {
      setState(() {
        _appliedFilter = result;
      });
    }
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
        title: const Text("Daftar Perawatan"),

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
                        // onPressed: () {},
                        onPressed: _openFilterSheet,
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

            final allItems = docs.map((d) => d.data()).toList();

            // =========================
            // FILTER BERDASARKAN MAINTENANCE FILTER
            // =========================
            final filteredByFilter = applyFilter(allItems, _appliedFilter);

            // =========================
            // FILTER SEARCH (NAMA / SKU)
            // =========================
            // Search diterapkan SETELAH filter utama,
            // agar hasil pencarian tetap relevan.
            final filtered = _searchQuery.isEmpty
                ? filteredByFilter
                : filteredByFilter.where((main) {
                    final name = (main.itemName ?? '').toLowerCase();
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

  Color _statusColor(String status) {
    return status == 'terlambat' ? Colors.red.shade100 : Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final name = main.itemName;
    final sku = main.sku ?? '-';
    final nextMaintenanceAt = _formatDate(main.nextMaintenanceAt);
    final intervalDays = main.intervalDays;
    final priority = main.priority;

    // helper build qlient status
    String _computedStatus() {
      final now = DateTime.now();
      final next = main.nextMaintenanceAt!.toDate();

      return next.isBefore(now) ? 'terlambat' : 'terjadwal';
    }

    final status = _computedStatus();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsMaintenancePage(maintenance: main),
          ),
        );
      },
      child: Material(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
