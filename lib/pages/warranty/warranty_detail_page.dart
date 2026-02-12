import 'package:flutter/material.dart';
import 'package:flutter_kita/models/warranty_model.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/repair/repair_add_page.dart';

class WarrantyDetailPage extends StatelessWidget {
  const WarrantyDetailPage({super.key, required this.warranty});

  final WarrantyModel warranty;

  @override
  Widget build(BuildContext context) {
    final startDate = _fmtDate(warranty.startAt);
    final expireDate = _fmtDate(warranty.expireAt);
    final remainingDays = warranty.expireAt.difference(DateTime.now()).inDays;

    late String statusText;
    late Color statusColor;

    if (warranty.isExpired) {
      statusText = 'Expired';
      statusColor = MyColors.primary;
    } else {
      statusText = 'Aktif';
      statusColor = MyColors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Garansi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F6F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= STATUS CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!warranty.isExpired)
                    Text(
                      'Sisa $remainingDays hari',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= INFO CARD =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoRow('Nama Pembeli', warranty.buyerName),
                  _divider(),
                  _infoRow('Produk', warranty.productName),
                  _divider(),
                  _infoRow('Serial Number', warranty.serialNumber),
                  _divider(),
                  _infoRow('Jenis Garansi', warranty.warrantyTypeLabel),
                  _divider(),
                  _infoRow(
                    'Jumlah Klaim',
                    warranty.claimCount == 0
                        ? 'Belum pernah diklaim'
                        : '${warranty.claimCount} kali',
                  ),
                  _divider(),
                  _infoRow('Tanggal Mulai', startDate),
                  _divider(),
                  _infoRow('Tanggal Berakhir', expireDate),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (warranty.isExpired) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Masa garansi sudah habis (Expired)'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RepairAddPage(
                        warrantyId: warranty.id,
                        warrantyData: {
                          'buyerName': warranty.buyerName,
                          'productName': warranty.productName,
                          'noHp': warranty.phone,
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.build_outlined),
                label: Text(
                  warranty.isExpired ? 'Garansi Expired' : 'Klaim Garansi',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warranty.isExpired
                      ? Colors.grey
                      : MyColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

Widget _divider() {
  return Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2));
}
