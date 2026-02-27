import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class InventoryFormFieldsSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController descCtrl;

  final String? selectedType;
  final String? selectedMerk;
  final int movementBaseScore;

  final ValueChanged<int> onMovementChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onMerkChanged;

  const InventoryFormFieldsSection({
    super.key,
    required this.nameCtrl,
    required this.skuCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.locationCtrl,
    required this.descCtrl,
    required this.selectedType,
    required this.selectedMerk,
    required this.onTypeChanged,
    required this.onMerkChanged,
    required this.movementBaseScore,
    required this.onMovementChanged,
  });

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration(String hint) {
      return const InputDecoration(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyColors.secondary, width: 2),
        ),
      ).copyWith(hintText: hint);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Nama Barang",
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: skuCtrl,
          decoration: const InputDecoration(
            labelText: "SKU",
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? "SKU wajib diisi" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Harga",
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Harga wajib diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: stockCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Jumlah Stok",
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Jumlah wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: locationCtrl,
          decoration: const InputDecoration(
            labelText: "Rak",
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? "Rak wajib diisi" : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedType,
          items: const [
            DropdownMenuItem(value: "unit", child: Text("Unit")),
            DropdownMenuItem(value: "part", child: Text("Part")),
          ],
          onChanged: onTypeChanged,
          decoration: const InputDecoration(
            labelText: "Tipe Barang",
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Tipe wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedMerk,
          items: const [
            DropdownMenuItem(value: "firman", child: Text("Firman")),
            DropdownMenuItem(
              value: "black+decker",
              child: Text("Black+Decker"),
            ),
            DropdownMenuItem(value: "stanley", child: Text("Stanley")),
            DropdownMenuItem(value: "dewalt", child: Text("Dewalt")),
          ],
          onChanged: onMerkChanged,
          decoration: const InputDecoration(
            labelText: "Merk",
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Merk wajib diisi' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: movementBaseScore,
          decoration: const InputDecoration(
            labelText: "Movement Speed",
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 1000, child: Text("Cepat")),
            DropdownMenuItem(value: 500, child: Text("Normal")),
            DropdownMenuItem(value: 100, child: Text("Jarang")),
          ],
          onChanged: (value) {
            if (value != null) {
              onMovementChanged(value);
            }
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descCtrl,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: "Deskripsi",
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
        ),
      ],
    );
  }
}
