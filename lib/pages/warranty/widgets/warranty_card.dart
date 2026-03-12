import 'package:flutter/material.dart';
import 'package:flutter_kita/models/warranty/warranty_model.dart';
import 'package:flutter_kita/styles/colors.dart';
import '../warranty_detail_page.dart';

class WarrantyCard extends StatelessWidget {
  const WarrantyCard({super.key, required this.warranty});

  final WarrantyModel warranty;

  @override
  Widget build(BuildContext context) {
    final expireText = _fmtDate(warranty.expireAt);
    final remainingDays = warranty.remainingDays;

    String countdownText;
    if (remainingDays < 0) {
      countdownText = "Sudah berakhir";
    } else {
      countdownText = "Sisa $remainingDays hari";
    }

    final claimText = warranty.isUnlimitedClaim
        ? "Claim ∞"
        : "Claim ${warranty.claimCount}/${warranty.maxClaim}";

    late String statusText;
    late Color bg;
    late Color fg;

    if (warranty.isExpired) {
      statusText = "Expire";
      bg = const Color(0xFFFFE5E5);
      fg = const Color(0xFFD32F2F);
    } else {
      statusText = "Aktif";
      bg = const Color(0xFFDFF7E5);
      fg = const Color(0xFF1E8A3D);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WarrantyDetailPage(warranty: warranty),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ROW 1 — DATE + STATUS
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: MyColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      expireText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: MyColors.secondary,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// NAMA BARANG
            Text(
              warranty.productName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 4),

            /// SERIAL NUMBER
            Text(
              "SN : ${warranty.serialNumber}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 2),

            /// NAMA PELANGGAN
            Text(
              warranty.buyerName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),

            const SizedBox(height: 10),

            /// FOOTER CLAIM + COUNTDOWN
            Row(
              children: [
                Text(
                  claimText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  "|",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  countdownText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: remainingDays < 30
                        ? Colors.red
                        : Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
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
