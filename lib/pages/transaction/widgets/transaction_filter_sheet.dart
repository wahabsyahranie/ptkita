import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_kita/styles/colors.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  final String currentFilter;
  final Function(String, DateTime?, DateTime?) onApply;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  String selected = "all";

  DateTime? startDate;
  DateTime? endDate;

  /// CHIP FILTER
  Widget chip(String value, String label) {
    final active = selected == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = value;
          startDate = null;
          endDate = null;
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

  /// PICK START DATE
  Future pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        startDate = date;
        selected = "custom";
      });
    }
  }

  /// PICK END DATE
  Future pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        endDate = date;
        selected = "custom";
      });
    }
  }

  /// FORMAT DATE
  String formatDate(DateTime? d) {
    if (d == null) return "Pilih";
    return DateFormat("dd MMM yyyy").format(d);
  }

  /// DATE BOX UI
  Widget dateBox(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.secondary),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                formatDate(date),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      decoration: const BoxDecoration(
        color: Color(0xFFF3E6D7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DRAG HANDLE
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// TITLE
            const Center(
              child: Text(
                "Filter Tanggal",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 22),

            /// QUICK FILTER
            const Text(
              "Rentang Cepat",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                chip("today", "Hari Ini"),
                chip("7days", "7 Hari"),
                chip("30days", "30 Hari"),
                chip("all", "Semua"),
              ],
            ),

            const SizedBox(height: 24),

            /// CUSTOM RANGE
            const Text(
              "Rentang Custom",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                dateBox("Start", startDate, pickStart),
                const SizedBox(width: 10),
                dateBox("End", endDate, pickEnd),
              ],
            ),

            const SizedBox(height: 28),

            /// BUTTON
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
                  widget.onApply(selected, startDate, endDate);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Simpan",
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
