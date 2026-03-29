import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/utils/formatters.dart';

class RepairReceiptView extends StatelessWidget {
  final Map<String, dynamic> data;

  const RepairReceiptView({super.key, required this.data});

  bool get _isWarranty =>
      (data['repairCategory'] ?? '').toString().toLowerCase() == 'warranty';

  bool get _isSelesai =>
      (data['status'] ?? '').toString().toLowerCase() == 'selesai';

  @override
  Widget build(BuildContext context) {
    final dynamic cost = data['cost'];
    final String formattedCost = cost != null
        ? Formatters.formatRupiah(cost)
        : "-";
    final String dateIn = Formatters.formatDate(data['date']);

    final String phone = (data['noHp'] ?? "-").toString();

    final String kelengkapan = (data['completeness'] ?? "-").toString();

    final String completedAt = Formatters.formatDate(data['completedAt']);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: MyColors.greySoft,
            boxShadow: [
              BoxShadow(
                color: MyColors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // 🔥 penting supaya auto-height
            children: [
              /// ================= HEADER =================
              const Text(
                "BUKTI PERBAIKAN",
                style: TextStyle(
                  color: MyColors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _buildStatusBadge(),
                  if (_isWarranty) ...[
                    const SizedBox(width: 8),
                    _buildWarrantyBadge(),
                  ],
                ],
              ),

              const SizedBox(height: 30),

              /// ================= INFO SECTION =================
              _buildRow("Nama Pelanggan", data['buyerName']),
              _buildRow("No WhatsApp", phone),
              _buildRow("Nama Barang", data['itemName']),
              _buildRow("Kelengkapan", kelengkapan),

              const SizedBox(height: 6),

              _buildRow("Tanggal Masuk", dateIn),
              _buildRow("Tanggal Selesai", completedAt),
              _buildRow("Teknisi", data['completedByName']),
              _buildRow("Rincian", data['detailPart']),

              const SizedBox(height: 24),

              /// ================= COST =================
              const Divider(color: MyColors.black),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Biaya",
                    style: TextStyle(color: MyColors.black, fontSize: 16),
                  ),
                  Text(
                    formattedCost,
                    style: const TextStyle(
                      color: MyColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ================= WATERMARK =================
              const Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.15,
                  child: Text(
                    "PT KITA SERVICE",
                    style: TextStyle(
                      color: MyColors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= BADGE STATUS =================
  Widget _buildStatusBadge() {
    final baseColor = _isSelesai ? MyColors.success : MyColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _isSelesai ? "SELESAI" : "PROSES",
        style: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// ================= BADGE WARRANTY =================
  Widget _buildWarrantyBadge() {
    // ignore: prefer_const_declarations
    final baseColor = MyColors.info;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 14, color: baseColor),
          const SizedBox(width: 4),
          Text(
            "GARANSI",
            style: TextStyle(
              color: baseColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= ROW BUILDER =================
  Widget _buildRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: MyColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value?.toString() ?? "-",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: MyColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DashedDivider(color: MyColors.black.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final Color color;

  const DashedDivider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
            .floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(width: dashWidth, height: 1, color: color);
          }),
        );
      },
    );
  }
}
