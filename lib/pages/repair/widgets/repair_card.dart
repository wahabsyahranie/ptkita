import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/repair/repair_model.dart';
import '../repair_detail_page.dart';

class RepairCard extends StatelessWidget {
  final RepairModel model;
  final VoidCallback? onUpdated;

  const RepairCard({super.key, required this.model, this.onUpdated});

  @override
  Widget build(BuildContext context) {
    final bool isDone = model.status == 'Selesai';
    final Color baseColor = isDone ? MyColors.success : MyColors.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RepairDetailPage(data: model.raw, docId: model.id),
            ),
          );

          if (result == true) {
            onUpdated?.call();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== TOP ROW =====
                Row(
                  children: [
                    /// STATUS BADGE (soft style)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        model.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: baseColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// WARRANTY BADGE
                    if (model.isGaransi)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Garansi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),

                    const Spacer(),

                    /// DATE WITH ICON
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: MyColors.secondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          model.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MyColors.secondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// BUYER (lebih subtle)
                Text(
                  model.buyer,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withValues(alpha: 0.80),
                  ),
                ),

                const SizedBox(height: 4),

                /// PRODUCT (headline utama)
                Text(
                  model.product,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 6),

                /// TECHNICIAN
                Text(
                  'Diperbaiki oleh ${model.technician}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
