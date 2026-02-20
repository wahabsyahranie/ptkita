import 'package:flutter/material.dart';
import '../../../models/repair/repair_summary_model.dart';
import '../../../styles/colors.dart';

class RepairProgressCard extends StatelessWidget {
  final Future<RepairSummaryModel> future;

  const RepairProgressCard({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepairSummaryModel>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final model = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColors.greySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Perbaikan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _progressRow(
                'Dalam perbaikan',
                model.dalamProgress,
                '${model.dalamPerbaikan}',
                Icons.build_outlined,
              ),
              const SizedBox(height: 16),
              _progressRow(
                'Selesai',
                model.selesaiProgress,
                '${model.selesai}',
                Icons.check_circle_outline,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _progressRow(String title, double value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MyColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(title), Text(label)],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: MyColors.white,
                valueColor: const AlwaysStoppedAnimation(MyColors.secondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
