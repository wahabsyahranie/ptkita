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
        const Text("Nama"),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameCtrl,
          decoration: decoration("Masukkan nama barang"),
          validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
        ),
        const SizedBox(height: 15),

        const Text("SKU"),
        const SizedBox(height: 8),
        TextFormField(
          controller: skuCtrl,
          decoration: decoration("Masukkan SKU barang"),
          validator: (v) => v == null || v.isEmpty ? "SKU wajib diisi" : null,
        ),
        const SizedBox(height: 15),

        const Text("Harga"),
        const SizedBox(height: 8),
        TextFormField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: decoration("Harga barang"),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Harga wajib diisi';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        const Text("Stok"),
        const SizedBox(height: 8),
        TextFormField(
          controller: stockCtrl,
          keyboardType: TextInputType.number,
          decoration: decoration("Masukkan jumlah stok"),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Jumlah wajib diisi' : null,
        ),
        const SizedBox(height: 15),

        const Text("Rak"),
        const SizedBox(height: 8),
        TextFormField(
          controller: locationCtrl,
          decoration: decoration("Masukkan kode rak"),
          validator: (v) => v == null || v.isEmpty ? "Rak wajib diisi" : null,
        ),
        const SizedBox(height: 15),

        const Text("Tipe"),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedType,
          items: const [
            DropdownMenuItem(value: "unit", child: Text("Unit")),
            DropdownMenuItem(value: "part", child: Text("Part")),
          ],
          onChanged: onTypeChanged,
          decoration: decoration("Pilih tipe barang"),
          validator: (v) => v == null || v.isEmpty ? 'Tipe wajib diisi' : null,
        ),
        const SizedBox(height: 15),

        const Text("Merk"),
        const SizedBox(height: 8),
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
          decoration: decoration("Pilih merk barang"),
          validator: (v) => v == null || v.isEmpty ? 'Merk wajib diisi' : null,
        ),
        const SizedBox(height: 15),

        const Text("Deskripsi"),
        const SizedBox(height: 8),
        TextFormField(
          controller: descCtrl,
          minLines: 4,
          maxLines: 8,
          decoration: decoration("Jelaskan deskripsi produk"),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
        ),
      ],
    );
  }
}
