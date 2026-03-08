import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

class TransactionSearchBar extends StatefulWidget {
  const TransactionSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  State<TransactionSearchBar> createState() => _TransactionSearchBarState();
}

class _TransactionSearchBarState extends State<TransactionSearchBar> {
  void _listener() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

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
              controller: widget.controller,
              onChanged: (_) => widget.onChanged(),
              decoration: const InputDecoration(
                hintText: 'Cari transaksi',
                hintStyle: TextStyle(color: MyColors.secondary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onChanged();
              },
              child: const Icon(Icons.close_rounded, color: MyColors.secondary),
            ),
        ],
      ),
    );
  }
}
