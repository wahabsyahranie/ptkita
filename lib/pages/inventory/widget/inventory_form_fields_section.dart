import 'package:flutter/material.dart';
import 'package:flutter_kita/models/brand/brand_model.dart';
import 'package:flutter_kita/services/brand/brand_service.dart';

class InventoryFormFieldsSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController typeUnitCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController descCtrl;
  final TextEditingController partNumberCtrl;
  final String? selectedcategory;
  final String? selectedMerk;
  final int movementBaseScore;
  final ValueChanged<int> onMovementChanged;
  final ValueChanged<String?> oncategoryChanged;
  final ValueChanged<String?> onMerkChanged;
  final BrandService brandService;
  final ValueChanged<Brand?> onBrandChanged;

  const InventoryFormFieldsSection({
    super.key,
    required this.brandService,
    required this.nameCtrl,
    required this.typeUnitCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.locationCtrl,
    required this.descCtrl,
    required this.selectedcategory,
    required this.selectedMerk,
    required this.oncategoryChanged,
    required this.onMerkChanged,
    required this.movementBaseScore,
    required this.onMovementChanged,
    required this.partNumberCtrl,
    required this.onBrandChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: typeUnitCtrl,
          decoration: const InputDecoration(
            labelText: "Type Unit",
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              v == null || v.isEmpty ? "Type Unit wajib diisi" : null,
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

            final parsed = int.tryParse(
              v.replaceAll(',', '').replaceAll('.', ''),
            );

            if (parsed == null) {
              return 'Harga harus berupa angka';
            }

            if (parsed < 0) {
              return 'Harga tidak boleh minus';
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
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Jumlah wajib diisi';
            }

            final parsed = int.tryParse(
              v.replaceAll(',', '').replaceAll('.', ''),
            );

            if (parsed == null) {
              return 'Jumlah harus berupa angka';
            }

            if (parsed < 0) {
              return 'Jumlah tidak boleh minus';
            }

            return null;
          },
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
          initialValue: selectedcategory,
          items: const [
            DropdownMenuItem(value: "unit", child: Text("Unit")),
            DropdownMenuItem(value: "part", child: Text("Part")),
          ],
          onChanged: oncategoryChanged,
          decoration: const InputDecoration(
            labelText: "Kategori Barang",
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              v == null || v.isEmpty ? 'Kategori wajib diisi' : null,
        ),
        if (selectedcategory == "part") ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: partNumberCtrl,
            decoration: const InputDecoration(
              labelText: "Part Number",
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (selectedcategory == "part") {
                if (v == null || v.trim().isEmpty) {
                  return "Part Number wajib diisi";
                }
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        StreamBuilder<List<Brand>>(
          stream: brandService.streamActiveBrands(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final brands = snapshot.data!;

            return DropdownButtonFormField<Brand>(
              initialValue:
                  brands
                      .where(
                        (b) =>
                            b.name.toLowerCase() == selectedMerk?.toLowerCase(),
                      )
                      .isNotEmpty
                  ? brands.firstWhere(
                      (b) =>
                          b.name.toLowerCase() == selectedMerk?.toLowerCase(),
                    )
                  : null,
              items: brands.map((b) {
                return DropdownMenuItem<Brand>(value: b, child: Text(b.name));
              }).toList(),
              onChanged: (brand) {
                if (brand != null) {
                  onMerkChanged(brand.name); // existing flow
                  onBrandChanged(brand); // tambahan baru
                }
              },
              decoration: const InputDecoration(
                labelText: "Merk",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Merk wajib diisi' : null,
            );
          },
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
