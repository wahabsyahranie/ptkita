import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/services/maintenance/maintenance_history_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class MaintenanceHistoryDetailPage extends StatefulWidget {
  final String historyId;

  const MaintenanceHistoryDetailPage({super.key, required this.historyId});

  @override
  State<MaintenanceHistoryDetailPage> createState() =>
      _MaintenanceHistoryDetailPageState();
}

class _MaintenanceHistoryDetailPageState
    extends State<MaintenanceHistoryDetailPage> {
  late final MaintenanceHistoryService _service;

  @override
  void initState() {
    super.initState();
    _service = MaintenanceHistoryService(FirestoreMaintenanceRepository());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MaintenanceHistory?>(
      stream: _service.streamHistoryDetail(widget.historyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Terjadi kesalahan")));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Riwayat tidak ditemukan")),
          );
        }

        final history = snapshot.data!;

        return Scaffold(
          backgroundColor: MyColors.white,
          appBar: AppBar(
            title: const Text("Detail Riwayat"),
            backgroundColor: MyColors.white,
            surfaceTintColor: Colors.transparent,
          ),
          body: _buildContent(history),
        );
      },
    );
  }

  Widget _buildContent(MaintenanceHistory history) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(history),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowInfo(
                  "Tanggal Terjadwal",
                  _service.formatDate(history.scheduledAt?.toDate()),
                ),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo(
                  "Tanggal Selesai",
                  _service.formatDate(history.completedAt.toDate()),
                ),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Keterlambatan", _service.formatLateDays(history)),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Interval", "${history.intervalDays} Hari"),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Prioritas", history.priority),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo(
                  "Jumlah Maintenance",
                  "${history.completedQuantity} Unit",
                ),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Teknisi", history.userName),

                const DottedlineWidget(),
                const SizedBox(height: 10),

                const Text(
                  "Catatan",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),

                const SizedBox(height: 6),

                const Text("-"),

                const DottedlineWidget(),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: MyColors.secondary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        fontSize: 18,
                        color: MyColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(MaintenanceHistory history) {
    final statusColor = _service.statusColor(history);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: MyColors.white,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                history.itemName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                history.partNumber == null || history.partNumber!.isEmpty
                    ? "-"
                    : "Part Number : ${history.partNumber}",
                style: TextStyle(color: MyColors.black.withValues(alpha: .6)),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _service.formatStatus(history),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Icon(Icons.autorenew, size: 18),

                  const SizedBox(width: 8),

                  Text(
                    _service.formatCycle(history.cycleNumber),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),

                  const SizedBox(width: 8),

                  Text("${history.completedQuantity} Unit dikerjakan"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),

        const SizedBox(width: 16),

        Expanded(child: Text(value, textAlign: TextAlign.end)),
      ],
    );
  }
}
