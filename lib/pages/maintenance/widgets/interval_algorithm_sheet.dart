import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class IntervalAlgorithmSheet extends StatelessWidget {
  final String lastMaintenance;
  final String nextMaintenance;
  final int intervalDays;

  const IntervalAlgorithmSheet({
    super.key,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.intervalDays,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.schedule, color: MyColors.secondary),
                  SizedBox(width: 10),
                  Text(
                    'Cara Kerja Penjadwalan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                'Aplikasi menggunakan Interval Scheduling Algorithm '
                'untuk menentukan jadwal maintenance berikutnya '
                'berdasarkan tanggal maintenance terakhir dan '
                'interval perawatan.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.6),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    if (lastMaintenance == 'belum pernah') ...[
                      const Text(
                        'Penjadwalan Pertama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Belum pernah dilakukan maintenance. '
                        'Jadwal maintenance pertama akan dihitung secara otomatis '
                        'berdasarkan interval yang telah ditentukan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ] else ...[
                      const Text(
                        'Maintenance Terakhir',
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        lastMaintenance,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 32,
                        color: MyColors.secondary,
                      ),

                      const SizedBox(height: 8),
                    ],

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.secondary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '+ $intervalDays Hari',
                        style: const TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 32,
                      color: MyColors.secondary,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Maintenance Berikutnya',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      nextMaintenance,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: MyColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Rumus Penjadwalan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Next Maintenance = Last Maintenance + Interval',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
