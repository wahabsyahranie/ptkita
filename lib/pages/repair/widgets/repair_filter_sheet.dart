import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class RepairFilterSheet extends StatefulWidget {
  const RepairFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  final String currentFilter;
  final Function(String) onApply;

  @override
  State<RepairFilterSheet> createState() => _RepairFilterSheetState();
}

class _RepairFilterSheetState extends State<RepairFilterSheet> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.currentFilter;
  }

  Widget _chip(String value, String label) {
    final active = selected == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? MyColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MyColors.secondary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : MyColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
        decoration: const BoxDecoration(
          color: Color(0xFFF3E6D7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// drag handle
            Container(
              width: 42,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              'Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _chip('all', 'Semua'),
                  _chip('done', 'Selesai'),
                  _chip('pending', 'Belum Selesai'),
                ],
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  widget.onApply(selected);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
