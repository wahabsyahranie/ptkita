import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/home/widgets/statistic_cards_skeleton.dart';
import '../../../styles/colors.dart';

class StatisticCards extends StatelessWidget {
  final Stream<int> totalItemsStream;
  final Stream<int> outOfStockStream;
  final VoidCallback onOutOfStockTap;
  final VoidCallback onTotalItemsTap;

  const StatisticCards({
    super.key,
    required this.totalItemsStream,
    required this.outOfStockStream,
    required this.onOutOfStockTap,
    required this.onTotalItemsTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: totalItemsStream,
      builder: (context, totalSnap) {
        if (!totalSnap.hasData) {
          return const StatisticCardsSkeleton();
        }

        return StreamBuilder<int>(
          stream: outOfStockStream,
          builder: (context, outSnap) {
            if (!outSnap.hasData) {
              return const StatisticCardsSkeleton();
            }

            return Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total Item',
                    '${totalSnap.data!}',
                    'Jenis barang terdaftar',
                    Icons.inventory_2_outlined,
                    onTap: onTotalItemsTap,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _statCard(
                    'Stok Habis',
                    '${outSnap.data!}',
                    'Stok yang kosong saat ini',
                    Icons.production_quantity_limits_outlined,
                    isAlert: outSnap.data! > 0,
                    onTap: onOutOfStockTap,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard(
    String title,
    String value,
    String subtitle,
    IconData icon, {
    bool isAlert = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: MyColors.greySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: MyColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 20, color: MyColors.secondary),
                    ),
                    if (isAlert)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: MyColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? MyColors.error : MyColors.black,
                ),
              ),
              const SizedBox(height: 15),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
