import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_history_model.dart';
import 'package:flutter_kita/services/maintenance/maintenance_history_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportRecentHistoryCard extends StatelessWidget {
  final MaintenanceHistory history;
  final MaintenanceHistoryService service;
  final VoidCallback? onTap;

  const ReportRecentHistoryCard({
    super.key,
    required this.history,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: MyColors.white,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: MyColors.greySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      history.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: service
                          .statusColor(history)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service.formatReportStatus(history),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: MyColors.black,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    service.formatDate(history.completedAt.toDate()),
                    style: TextStyle(
                      color: MyColors.black.withValues(alpha: 0.75),
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: MyColors.black,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    '${history.completedQuantity} Unit',
                    style: TextStyle(
                      color: MyColors.black.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
