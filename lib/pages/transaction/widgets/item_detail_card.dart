import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/forms/app_text.dart';
import '../../../styles/colors.dart';

class ItemDetailCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int qty;
  final int stock;

  final bool hasWarranty;
  final int warrantyYear;
  final String warrantyType;

  final int? claimLimit;
  final ValueChanged<int?> onClaimLimitChanged;

  final List<TextEditingController>? serialControllers;

  final VoidCallback onClose;
  final VoidCallback onQtyAdd;
  final VoidCallback? onQtyMinus;

  final ValueChanged<bool> onWarrantyChanged;
  final ValueChanged<int> onWarrantyYearChanged;
  final ValueChanged<String> onWarrantyTypeChanged;

  const ItemDetailCard({
    super.key,
    required this.item,
    required this.qty,
    required this.stock,
    required this.hasWarranty,
    required this.warrantyYear,
    required this.warrantyType,
    required this.claimLimit,
    required this.onClaimLimitChanged,
    this.serialControllers,
    required this.onClose,
    required this.onQtyAdd,
    required this.onQtyMinus,
    required this.onWarrantyChanged,
    required this.onWarrantyYearChanged,
    required this.onWarrantyTypeChanged,
  });

  String _fmt(int v) {
    final s = v.toString().split('').reversed.toList();
    final parts = <String>[];

    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }

    return parts.reversed.join('.');
  }

  Widget _subLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );

  Widget _qtyButton({required IconData icon, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MyColors.secondary.withValues(alpha: 0.6)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey : MyColors.secondary,
        ),
      ),
    );
  }

  Widget _radioBool({
    required String label,
    required bool value,
    required bool group,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          // ignore: deprecated_member_use
          groupValue: group,
          activeColor: MyColors.secondary,
          // ignore: deprecated_member_use
          onChanged: (v) => onChanged(v!),
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = item['price'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Rp ${_fmt(price)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    stock == 0 ? 'Stok: Habis' : 'Stok: $stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: stock == 0 ? Colors.red : Colors.black,
                      fontWeight: stock == 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),

          const SizedBox(height: 12),

          /// QTY
          _subLabel('Jumlah'),
          Row(
            children: [
              _qtyButton(icon: Icons.remove, onTap: onQtyMinus),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$qty',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _qtyButton(icon: Icons.add, onTap: onQtyAdd),
            ],
          ),

          const SizedBox(height: 14),

          /// WARRANTY (HANYA UNTUK UNIT)
          if (item['category'] == 'unit') ...[
            _subLabel('Garansi'),

            Row(
              children: [
                _radioBool(
                  label: 'Ada',
                  value: true,
                  group: hasWarranty,
                  onChanged: onWarrantyChanged,
                ),
                _radioBool(
                  label: 'Tidak Ada',
                  value: false,
                  group: hasWarranty,
                  onChanged: onWarrantyChanged,
                ),
              ],
            ),

            /// SERIAL NUMBER (UNTUK UNIT)
            if (item['category'] == 'unit' && serialControllers != null) ...[
              const SizedBox(height: 6),

              ...List.generate(serialControllers!.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppTextFormField(
                    controller: serialControllers![i],
                    label: 'Serial Number ${i + 1}',
                  ),
                );
              }),
            ],

            if (hasWarranty) ...[
              const SizedBox(height: 14),

              const SizedBox(height: 14),

              DropdownMenu<int>(
                width: MediaQuery.of(context).size.width * 0.5,
                label: const Text("Durasi Garansi"),
                initialSelection: warrantyYear,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 1, label: "1 Tahun"),
                  DropdownMenuEntry(value: 2, label: "2 Tahun"),
                  DropdownMenuEntry(value: 3, label: "3 Tahun"),
                ],
                onSelected: (v) {
                  if (v != null) {
                    onWarrantyYearChanged(v);
                  }
                },
              ),

              const SizedBox(height: 14),

              DropdownMenu<String>(
                width: MediaQuery.of(context).size.width * 0.5,
                label: const Text("Jenis Garansi"),
                initialSelection: warrantyType,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'Jasa', label: 'Jasa'),
                  DropdownMenuEntry(value: 'SparePart', label: 'SparePart'),
                  DropdownMenuEntry(
                    value: 'Jasa & SparePart',
                    label: 'Jasa & SparePart',
                  ),
                ],
                onSelected: (v) {
                  if (v != null) {
                    onWarrantyTypeChanged(v);
                  }
                },
              ),

              const SizedBox(height: 14),

              DropdownMenu<int?>(
                width: MediaQuery.of(context).size.width * 0.5,
                label: const Text("Batas Klaim"),
                initialSelection: claimLimit,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: null, label: "Tidak terbatas"),
                  DropdownMenuEntry(value: 1, label: "1 Kali"),
                  DropdownMenuEntry(value: 2, label: "2 Kali"),
                  DropdownMenuEntry(value: 3, label: "3 Kali"),
                  DropdownMenuEntry(value: 5, label: "5 Kali"),
                ],
                onSelected: onClaimLimitChanged,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
