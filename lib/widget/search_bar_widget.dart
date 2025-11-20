import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MyColors.secondary, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: MyColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: TextStyle(
                color: MyColors.secondary,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              cursorColor: MyColors.secondary,
              decoration: InputDecoration(
                hintText: 'Cari sesuatu...',
                hintStyle: TextStyle(
                  color: MyColors.secondary.withOpacity(0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
