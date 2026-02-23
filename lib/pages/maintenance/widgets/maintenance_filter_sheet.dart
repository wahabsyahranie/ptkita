import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_filter_model.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceFilterSheet extends StatefulWidget {
  final MaintenanceFilter? initialFilter;
  const MaintenanceFilterSheet({super.key, this.initialFilter});

  @override
  State<MaintenanceFilterSheet> createState() => _MaintenanceFilterSheetState();
}

class _MaintenanceFilterSheetState extends State<MaintenanceFilterSheet> {
  late Set<String> statuses;
  late Set<String> priorities;
  Duration? timeRange;

  @override
  void initState() {
    super.initState();
    statuses = {...?widget.initialFilter?.statuses};
    priorities = {...?widget.initialFilter?.priorities};
    timeRange = widget.initialFilter?.timeRange;
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
                "Filter Perawatan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // STATUS
            // =========================
            const Text("Status", style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: ['terlambat', 'terjadwal'].map((s) {
                return _chipButton(
                  label: s,
                  selected: statuses.contains(s),
                  onTap: () {
                    setState(() {
                      statuses.contains(s)
                          ? statuses.remove(s)
                          : statuses.add(s);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // =========================
            // PRIORITAS
            // =========================
            const Text(
              "Prioritas",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: ['rendah', 'sedang', 'tinggi'].map((p) {
                return _chipButton(
                  label: p,
                  selected: priorities.contains(p),
                  onTap: () {
                    setState(() {
                      priorities.contains(p)
                          ? priorities.remove(p)
                          : priorities.add(p);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // =========================
            // WAKTU
            // =========================
            const Text("Waktu", style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12, // jarak horizontal
              runSpacing: 12, // 🔥 jarak vertikal antar baris
              children: [
                _timeChip("1 Hari", const Duration(days: 1)),
                _timeChip("1 Minggu", const Duration(days: 7)),
                _timeChip("1 Bulan", const Duration(days: 30)),
                _timeChip("1 Tahun", const Duration(days: 365)),
              ],
            ),

            const SizedBox(height: 30),

            // =========================
            // SIMPAN BUTTON
            // =========================
            GestureDetector(
              onTap: () {
                Navigator.pop(
                  context,
                  MaintenanceFilter(
                    statuses: statuses,
                    priorities: priorities,
                    timeRange: timeRange,
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
                  "Simpan",
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
  // CHIP BUTTON (SAMA DENGAN INVENTORY)
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

  Widget _timeChip(String label, Duration value) {
    return _chipButton(
      label: label,
      selected: timeRange == value,
      onTap: () {
        setState(() {
          timeRange = timeRange == value ? null : value;
        });
      },
    );
  }
}
