import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart'; // sesuaikan nama package jika perlu

/// Reusable search bar widget dengan controller, hint, dan onChanged.
class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Cari sesuatu...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MyColors.secondary, width: 1.5),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: MyColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller, // ← DITAMBAHKAN
              onChanged: onChanged, // ← DITAMBAHKAN
              style: TextStyle(
                color: MyColors.secondary,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              cursorColor: MyColors.secondary,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: MyColors.secondary.withOpacity(0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          // optional: clear button that appears when text exists
          // ValueListenableBuilder<TextEditingValue>(
          //   valueListenable: controller,
          //   builder: (_, value, __) {
          //     if (value.text.isEmpty) return const SizedBox.shrink();
          //     return GestureDetector(
          //       onTap: () {
          //         controller.clear();
          //         if (onChanged != null) onChanged!('');
          //       },
          //       child: Icon(
          //         Icons.close_rounded,
          //         color: MyColors.secondary.withOpacity(0.7),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
