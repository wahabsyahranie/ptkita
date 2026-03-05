import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

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

  InputDecoration _inputDecoration({String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: MyColors.secondary, width: 1.5),
      ),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nama Pelanggan'),
        TextField(
          controller: nameCtrl,
          decoration: _inputDecoration(hint: 'Nama pelanggan'),
        ),

        const SizedBox(height: 14),

        _label('No. HP'),
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(hint: '08xxxxxxxxxx'),
        ),

        const SizedBox(height: 14),

        _label('Tanggal Transaksi'),
        TextField(
          controller: dateCtrl,
          readOnly: true,
          decoration: _inputDecoration(
            hint: 'Pilih tanggal',
            suffixIcon: Icons.calendar_today_rounded,
          ),
          onTap: onPickDate,
        ),
      ],
    );
  }
}
