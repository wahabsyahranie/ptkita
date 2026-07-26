import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class ReportPeriodSheet extends StatefulWidget {
  const ReportPeriodSheet({super.key, this.initialRange});

  final DateTimeRange? initialRange;

  @override
  State<ReportPeriodSheet> createState() => _ReportPeriodSheetState();
}

class _ReportPeriodSheetState extends State<ReportPeriodSheet> {
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    selectedRange = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // DRAG BAR
            // =========================
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: MyColors.greySoft,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =========================
            // TITLE
            // =========================
            const Center(
              child: Text(
                'Periode Custom',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // PERIODE
            // =========================
            const Text(
              'Rentang Tanggal',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.greySoft),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  selectedRange == null
                      ? 'Pilih rentang tanggal'
                      : '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}',
                  style: TextStyle(
                    color: selectedRange == null ? Colors.grey : MyColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // APPLY
            // =========================
            GestureDetector(
              onTap: selectedRange == null
                  ? null
                  : () {
                      Navigator.pop(context, selectedRange);
                    },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: selectedRange == null
                      ? MyColors.greySoft
                      : MyColors.secondary,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Terapkan',
                  style: TextStyle(
                    fontSize: 18,
                    color: MyColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // =========================
  // DATE RANGE PICKER
  // =========================
  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
    );

    if (result == null) return;

    setState(() {
      selectedRange = result;
    });
  }

  // =========================
  // FORMAT DATE
  // =========================
  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
