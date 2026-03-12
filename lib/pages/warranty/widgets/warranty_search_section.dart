import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

class WarrantySearchSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearch;

  const WarrantySearchSection({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SearchBarWidget(
              controller: controller,
              hintText: 'Nama Pembeli / SN',
              onChanged: onSearch,
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: MyColors.secondary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.filter_alt,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
