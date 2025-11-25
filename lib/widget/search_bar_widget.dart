import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Cari sesuatu...',
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final String hintText;

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

          // TEXTFIELD
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
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
              ),
            ),
          ),

          // CLEAR BUTTON
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged();
              },
              child: Icon(
                Icons.close_rounded,
                color: MyColors.secondary.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }
}
