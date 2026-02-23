import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'repair_info_row.dart';

class RepairDetailCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSelesai;
  final bool isWarranty;
  final String dateText;
  final String detailPart;
  final dynamic cost;
  final Widget? bottomSection;

  const RepairDetailCard({
    super.key,
    required this.data,
    required this.isSelesai,
    required this.isWarranty,
    required this.dateText,
    required this.detailPart,
    required this.cost,
    this.bottomSection,
  });

  @override
  Widget build(BuildContext context) {
    final buyer = data['buyerName'] ?? '-';
    final item = data['itemName'] ?? '-';
    final tech = data['techName'] ?? '-';
    final phone = data['noHp'] ?? '-';
    final completeness = data['completeness'] ?? '-';
    final warrantySnapshot = data['warrantySnapshot'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          RepairInfoRow(label: 'Nama Pelanggan', value: buyer),
          const DottedlineWidget(),
          RepairInfoRow(label: 'Nama Barang', value: item),
          const DottedlineWidget(),
          RepairInfoRow(label: 'Teknisi', value: tech),
          const DottedlineWidget(),
          RepairInfoRow(label: 'Tanggal Masuk', value: dateText),
          const DottedlineWidget(),
          RepairInfoRow(label: 'No Whatsapps', value: phone),
          const DottedlineWidget(),
          RepairInfoRow(label: 'Kelengkapan', value: completeness),
          const DottedlineWidget(),

          if (isWarranty && warrantySnapshot != null) ...[
            RepairInfoRow(
              label: 'Jenis Garansi',
              value: warrantySnapshot['warrantyType'] ?? '-',
            ),
            const DottedlineWidget(),
            RepairInfoRow(
              label: 'Klaim ke-',
              value: ((warrantySnapshot['claimCountBefore'] ?? 0) + 1)
                  .toString(),
            ),
            const DottedlineWidget(),
          ],

          if (isSelesai) ...[
            const SizedBox(height: 16),
            RepairInfoRow(
              label: 'Diselesaikan Oleh',
              value: data['completedByName'] ?? '-',
            ),
            const SizedBox(height: 8),
            RepairInfoRow(
              label: 'Tanggal Selesai',
              value: data['completedAt']?.toString() ?? '-',
            ),
            const SizedBox(height: 8),
            RepairInfoRow(label: 'Rincian', value: detailPart),
            const SizedBox(height: 8),
            RepairInfoRow(
              label: 'Biaya',
              value: isWarranty
                  ? 'Gratis (Garansi)'
                  : cost == null
                  ? '-'
                  : cost.toString(),
            ),
          ],

          if (bottomSection != null) ...[
            const SizedBox(height: 20),
            bottomSection!,
          ],
        ],
      ),
    );
  }
}
