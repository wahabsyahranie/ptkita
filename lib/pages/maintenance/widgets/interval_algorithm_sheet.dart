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
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: MyColors.greySoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Cara Kerja Penjadwalan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Aplikasi menggunakan Interval Scheduling Algorithm untuk menentukan jadwal maintenance berikutnya berdasarkan tanggal maintenance terakhir dan interval perawatan yang telah ditentukan.',
                style: TextStyle(fontSize: 15, height: 1.6),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MyColors.greySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (lastMaintenance == 'belum pernah') ...[
                      const Text(
                        'Penjadwalan Pertama',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Belum pernah dilakukan maintenance sehingga jadwal maintenance pertama akan dihitung secara otomatis berdasarkan interval yang telah ditentukan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.5),
                      ),

                      const SizedBox(height: 20),
                    ] else ...[
                      const Text(
                        'Maintenance Terakhir',
                        style: TextStyle(
                          color: MyColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        lastMaintenance,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: MyColors.secondary,
                        size: 30,
                      ),

                      const SizedBox(height: 10),
                    ],

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.secondary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '+ $intervalDays Hari',
                        style: const TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: MyColors.secondary,
                      size: 30,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Maintenance Berikutnya',
                      style: TextStyle(
                        color: MyColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      nextMaintenance,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MyColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Rumus Penjadwalan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: MyColors.greySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Next Maintenance = Last Maintenance + Interval',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MyColors.secondary,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontSize: 18,
                      color: MyColors.white,
                      fontWeight: FontWeight.w600,
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
}
