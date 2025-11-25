import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart'; // sesuaikan nama package jika perlu

/// Reusable search bar widget dengan controller, hint, dan onChanged.
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = 'Cari sesuatu...',
    this.onChanged,
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
              controller: controller, // <- pake controller parent
              onChanged: onChanged, // <- optional callback
              style: TextStyle(
                color: MyColors.secondary,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              cursorColor: MyColors.secondary,
              decoration: InputDecoration(
                hintText: hintText, // <- pake hintText param
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
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  controller.clear();
                  if (onChanged != null) onChanged!('');
                },
                child: Icon(
                  Icons.close_rounded,
                  color: MyColors.secondary.withOpacity(0.7),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
