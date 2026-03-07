import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/forms/app_text.dart';

class CustomerForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController dateCtrl;

  final VoidCallback onPickDate;

  const CustomerForm({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.dateCtrl,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// NAMA PELANGGAN
        AppTextFormField(controller: nameCtrl, label: 'Nama Pelanggan'),

        const SizedBox(height: 14),

        /// NO HP
        AppTextFormField(
          controller: phoneCtrl,
          label: 'No. HP',
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 14),

        /// TANGGAL
        AppTextFormField(
          controller: dateCtrl,
          label: 'Pilih Tanggal Transaksi',
          readOnly: true,
          onTap: onPickDate,
        ),
      ],
    );
  }
}
