import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class WarrantyFilterSheet extends StatelessWidget {
  final String currentFilter;
  final Function(String) onApply;

  const WarrantyFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  Widget _buildFilterOption({
    required String label,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    final bool selected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? MyColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MyColors.secondary),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : MyColors.secondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String tempFilter = currentFilter;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(width: 40, child: Divider(thickness: 4)),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterOption(
                    label: 'Semua',
                    value: 'all',
                    groupValue: tempFilter,
                    onChanged: (v) => setModalState(() => tempFilter = v),
                  ),

                  _buildFilterOption(
                    label: 'Aktif',
                    value: 'active',
                    groupValue: tempFilter,
                    onChanged: (v) => setModalState(() => tempFilter = v),
                  ),

                  _buildFilterOption(
                    label: 'Expired',
                    value: 'expired',
                    groupValue: tempFilter,
                    onChanged: (v) => setModalState(() => tempFilter = v),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    onApply(tempFilter);
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
        );
      },
    );
  }
}
