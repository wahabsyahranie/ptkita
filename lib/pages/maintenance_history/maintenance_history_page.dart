import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_filter_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/pages/maintenance_history/widgets/maintenance_history_box.dart';
import 'package:flutter_kita/pages/maintenance_history/widgets/maintenance_history_detail_page.dart';
import 'package:flutter_kita/pages/maintenance_history/widgets/maintenance_history_empty_state.dart';
import 'package:flutter_kita/pages/maintenance_history/widgets/maintenance_history_filter_sheet.dart';
import 'package:flutter_kita/pages/maintenance_history/widgets/maintenance_history_list_skeleton.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/services/maintenance/maintenance_history_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

class MaintenanceHistoryPage extends StatefulWidget {
  const MaintenanceHistoryPage({super.key});

  @override
  State<MaintenanceHistoryPage> createState() => _MaintenanceHistoryPageState();
}

class _MaintenanceHistoryPageState extends State<MaintenanceHistoryPage> {
  final _repository = FirestoreMaintenanceRepository();
  late final MaintenanceHistoryService _service;

  final TextEditingController _searchCtrl = TextEditingController();

  Timer? _searchDebounce;

  String _searchQuery = '';

  MaintenanceHistoryFilter? _appliedFilter;

  @override
  void initState() {
    super.initState();

    _service = MaintenanceHistoryService(_repository);

    _appliedFilter = const MaintenanceHistoryFilter();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

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
        _searchQuery = value.trim().toLowerCase();
      });
    });
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<MaintenanceHistoryFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColors.white,
      useSafeArea: true,
      builder: (_) {
        return MaintenanceHistoryFilterSheet(initialFilter: _appliedFilter);
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
        title: const Text("Riwayat Perawatan"),

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
                        hintText: 'Cari barang, part, atau teknisi',
                        onChanged: _onSearchChanged,
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
        child: StreamBuilder<List<MaintenanceHistory>>(
          stream: _service.streamHistory(
            filter: _appliedFilter,
            searchQuery: _searchQuery,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const MaintenanceHistoryListSkeleton();
            }

            final histories = snapshot.data!;

            if (histories.isEmpty) {
              return const MaintenanceHistoryEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: histories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return MaintenanceHistoryBox(
                  history: histories[index],
                  service: _service,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaintenanceHistoryDetailPage(
                          historyId: histories[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
