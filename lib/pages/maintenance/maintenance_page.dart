import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_filter_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/add_edit_maintenance_page.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_empty_state.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_filter_sheet.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_box.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final _repository = FirestoreMaintenanceRepository();
  late final MaintenanceService _service;

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

  @override
  void initState() {
    super.initState();

    _service = MaintenanceService(_repository);

    _appliedFilter = const MaintenanceFilter(
      statuses: {'terlambat', 'terjadwal'},
      timeRange: Duration(days: 1),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: MyColors.black.withValues(alpha: 0.25),
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
                          color: MyColors.white,
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
                          color: MyColors.white,
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
        child: StreamBuilder<List<Maintenance>>(
          stream: _service.streamMaintenance(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: MyColors.secondary),
              );
            }

            final allItems = snapshot.data!;
            if (allItems.isEmpty) {
              return const Center(child: Text('Belum ada perawatan.'));
            }

            // =========================
            // FILTER BERDASARKAN MAINTENANCE FILTER
            // =========================
            final filteredByFilter = _service.applyFilter(
              allItems,
              _appliedFilter,
            );

            // =========================
            // FILTER SEARCH (NAMA / SKU)
            // =========================
            // Search diterapkan SETELAH filter utama,
            // agar hasil pencarian tetap relevan.
            final filtered = _service.applySearch(
              filteredByFilter,
              _searchQuery,
            );
            if (filtered.isEmpty) {
              return const MaintenanceEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final main = filtered[idx];
                final status = _service.computeStatus(main);

                return MaintenanceBox(main: main, status: status);
              },
            );
          },
        ),
      ),
    );
  }
}
