import 'package:flutter/material.dart';
import '../../../styles/colors.dart';

class ItemDetailCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int qty;
  final int stock;

  final bool hasWarranty;
  final int warrantyYear;
  final String warrantyType;

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

  Widget _radioInt({
    required String label,
    required int value,
    required int group,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Radio<int>(
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

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: MyColors.secondary, width: 1.5),
      ),
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
                  Text('Stok: $stock', style: const TextStyle(fontSize: 12)),
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

          /// SERIAL NUMBER (UNTUK UNIT)
          if (item['category'] == 'unit' && serialControllers != null) ...[
            _subLabel('Serial Number'),

            const SizedBox(height: 6),

            ...List.generate(serialControllers!.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: serialControllers![i],
                  decoration: _inputDecoration(hint: 'Serial Number ${i + 1}'),
                ),
              );
            }),

            const SizedBox(height: 14),
          ],

          /// WARRANTY
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

          if (hasWarranty) ...[
            const SizedBox(height: 14),

            _subLabel('Durasi Garansi'),

            Row(
              children: [
                _radioInt(
                  label: '1 Tahun',
                  value: 1,
                  group: warrantyYear,
                  onChanged: onWarrantyYearChanged,
                ),
                _radioInt(
                  label: '2 Tahun',
                  value: 2,
                  group: warrantyYear,
                  onChanged: onWarrantyYearChanged,
                ),
              ],
            ),

            const SizedBox(height: 14),

            _subLabel('Jenis Garansi'),

            DropdownButtonFormField<String>(
              initialValue: warrantyType,
              items: const [
                DropdownMenuItem(value: 'Jasa', child: Text('Jasa')),
                DropdownMenuItem(value: 'SparePart', child: Text('SparePart')),
                DropdownMenuItem(
                  value: 'Jasa & SparePart',
                  child: Text('Jasa & SparePart'),
                ),
              ],
              onChanged: (v) => onWarrantyTypeChanged(v!),
              decoration: _inputDecoration(hint: 'Pilih jenis garansi'),
            ),
          ],
        ],
      ),
    );
  }
}
