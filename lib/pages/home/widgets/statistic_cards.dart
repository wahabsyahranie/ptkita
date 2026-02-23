import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

class StatisticCards extends StatelessWidget {
  final Stream<int> totalItemsStream;
  final Stream<int> outOfStockStream;
  final VoidCallback onOutOfStockTap;

  const StatisticCards({
    super.key,
    required this.totalItemsStream,
    required this.outOfStockStream,
    required this.onOutOfStockTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            stream: totalItemsStream,
            title: 'Total Item',
            subtitle: 'Jenis barang terdaftar',
            icon: Icons.inventory_2_outlined,
            isAlertCondition: (value) => value < 0,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildCard(
            stream: outOfStockStream,
            title: 'Stok Habis',
            subtitle: 'Stok yang kosong saat ini',
            icon: Icons.production_quantity_limits_outlined,
            isAlertCondition: (value) => value > 0,
            onTap: onOutOfStockTap,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required Stream<int> stream,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool Function(int) isAlertCondition,
    VoidCallback? onTap,
  }) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _statCard(title, '...', 'Memuat data', icon);
        }

        final value = snapshot.data!;
        return _statCard(
          title,
          '$value',
          subtitle,
          icon,
          isAlert: isAlertCondition(value),
          onTap: onTap,
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
