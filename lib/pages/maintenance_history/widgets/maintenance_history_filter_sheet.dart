import 'package:flutter/material.dart';
import 'package:flutter_kita/core/enum/maintenance_history_date_filter.dart';
import 'package:flutter_kita/core/enum/maintenance_history_status.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_filter_model.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryFilterSheet extends StatefulWidget {
  final MaintenanceHistoryFilter? initialFilter;

  const MaintenanceHistoryFilterSheet({super.key, this.initialFilter});

  @override
  State<MaintenanceHistoryFilterSheet> createState() =>
      _MaintenanceHistoryFilterSheetState();
}

class _MaintenanceHistoryFilterSheetState
    extends State<MaintenanceHistoryFilterSheet> {
  late Set<MaintenanceHistoryStatus> statuses;

  late MaintenanceHistoryDateFilter dateFilter;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    statuses = {...?widget.initialFilter?.statuses};

    dateFilter =
        widget.initialFilter?.dateFilter ?? MaintenanceHistoryDateFilter.all;

    startDate = widget.initialFilter?.startDate;
    endDate = widget.initialFilter?.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // DRAG BAR
            // =========================
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: MyColors.greySoft,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // TITLE
            // =========================
            const Center(
              child: Text(
                'Filter Riwayat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // STATUS
            // =========================
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),

            const SizedBox(height: 10),

            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: MaintenanceHistoryStatus.values.map((status) {
                return _chipButton(
                  label: _formatStatus(status),
                  selected: statuses.contains(status),
                  onTap: () {
                    setState(() {
                      statuses.contains(status)
                          ? statuses.remove(status)
                          : statuses.add(status);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // =========================
            // PERIODE
            // =========================
            const Text(
              'Periode',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dateChip('Hari Ini', MaintenanceHistoryDateFilter.today),
                _dateChip(
                  '7 Hari Terakhir',
                  MaintenanceHistoryDateFilter.last7Days,
                ),
                _dateChip(
                  '30 Hari Terakhir',
                  MaintenanceHistoryDateFilter.last30Days,
                ),
                _dateChip('Semua', MaintenanceHistoryDateFilter.all),
              ],
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                Navigator.pop(
                  context,
                  MaintenanceHistoryFilter(
                    statuses: statuses,
                    dateFilter: dateFilter,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Terapkan',
                  style: TextStyle(
                    fontSize: 18,
                    color: MyColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // =========================
  // CHIP BUTTON
  // =========================
  Widget _chipButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: selected ? MyColors.secondary : MyColors.white,
          border: Border.all(
            color: selected ? MyColors.secondary : MyColors.greySoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? MyColors.white : MyColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // =========================
  // DATE CHIP
  // =========================
  Widget _dateChip(String label, MaintenanceHistoryDateFilter value) {
    return _chipButton(
      label: label,
      selected: dateFilter == value,
      onTap: () {
        setState(() {
          dateFilter = value;

          final now = DateTime.now();

          switch (value) {
            case MaintenanceHistoryDateFilter.today:
              startDate = DateTime(now.year, now.month, now.day);

              endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              break;

            case MaintenanceHistoryDateFilter.last7Days:
              startDate = now.subtract(const Duration(days: 7));
              endDate = now;
              break;

            case MaintenanceHistoryDateFilter.last30Days:
              startDate = now.subtract(const Duration(days: 30));
              endDate = now;
              break;

            case MaintenanceHistoryDateFilter.all:
              startDate = null;
              endDate = null;
              break;
          }
        });
      },
    );
  }

  // =========================
  // FORMAT STATUS
  // =========================
  String _formatStatus(MaintenanceHistoryStatus status) {
    switch (status) {
      case MaintenanceHistoryStatus.completed:
        return 'Completed';

      case MaintenanceHistoryStatus.skipped:
        return 'Skipped';
    }
  }
}
