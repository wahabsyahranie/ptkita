import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_kita/core/widgets/forms/app_text.dart';

class CustomerForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController dateCtrl;
  final TextEditingController serviceFeeCtrl;

  final VoidCallback onPickDate;

  const CustomerForm({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.dateCtrl,
    required this.serviceFeeCtrl,
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

        const SizedBox(height: 14),

        /// BIAYA JASA
        AppTextFormField(
          controller: serviceFeeCtrl,
          label: 'Biaya Jasa',
          keyboardType: TextInputType.number,

          onChanged: (value) {
            /// ambil angka saja
            String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

            if (digits.isEmpty) {
              serviceFeeCtrl.clear();
              return;
            }

            /// format rupiah
            final formatted = NumberFormat.decimalPattern(
              'id_ID',
            ).format(int.parse(digits));

            serviceFeeCtrl.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
        ),
      ],
    );
  }
}
