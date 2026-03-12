import 'package:flutter/material.dart';
import 'package:flutter_kita/utils/formatters.dart';
// import 'package:flutter_kita/styles/colors.dart';

class CompleteRepairSheet extends StatelessWidget {
  final TextEditingController detailCtrl;
  final TextEditingController costCtrl;
  final VoidCallback onSubmit;

  const CompleteRepairSheet({
    super.key,
    required this.detailCtrl,
    required this.costCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== DRAG INDICATOR =====
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),

              const Text(
                "Selesaikan Perbaikan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextField(
            controller: detailCtrl,
            decoration: const InputDecoration(
              labelText: "Rincian Perbaikan",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          TextField(
            controller: costCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Biaya",
              prefixText: "Rp ",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

              if (digits.isEmpty) {
                costCtrl.clear();
                return;
              }

              final number = int.parse(digits);
              final formatted = Formatters.formatRupiah(number);

              costCtrl.value = TextEditingValue(
                text: formatted.replaceAll('Rp ', ''),
                selection: TextSelection.collapsed(
                  offset: formatted.replaceAll('Rp ', '').length,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: const Text("Simpan & Tandai Selesai"),
            ),
          ),
        ],
      ),
    );
  }
}
