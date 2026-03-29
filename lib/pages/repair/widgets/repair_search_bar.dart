import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class RepairSearchBar extends StatelessWidget {
  const RepairSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: MyColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: MyColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Cari riwayat perbaikan',
                hintStyle: TextStyle(color: MyColors.secondary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Icon(Icons.close_rounded, color: MyColors.secondary),
            ),
        ],
      ),
    );
  }
}
