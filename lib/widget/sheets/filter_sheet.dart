import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? availability; // "tersedia" | "habis"
  String? category; // "part" | "unit"
  final Set<String> selectedBrands = {};

  final brands = ["firman", "stanley", "dewalt", "black+decker"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag bar
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 15),

            const Center(
              child: Text(
                "Filter",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Ketersediaan",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                _chipButton(
                  label: "Tersedia",
                  selected: availability == "tersedia",
                  onTap: () => setState(() => availability = "tersedia"),
                ),
                const SizedBox(width: 12),
                _chipButton(
                  label: "Habis",
                  selected: availability == "habis",
                  onTap: () => setState(() => availability = "habis"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Kategori",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _chipButton(
                  label: "Part",
                  selected: category == "part",
                  onTap: () => setState(() => category = "part"),
                ),
                const SizedBox(width: 12),
                _chipButton(
                  label: "Unit",
                  selected: category == "unit",
                  onTap: () => setState(() => category = "unit"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Merk", style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: brands.map((b) {
                return FilterChip(
                  backgroundColor: Colors.white,
                  selected: selectedBrands.contains(b),
                  selectedColor: MyColors.secondary.withOpacity(0.2),
                  checkmarkColor: MyColors.secondary,
                  label: Text(b),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? selectedBrands.add(b)
                          : selectedBrands.remove(b);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                // kirim hasil filter
                Navigator.pop(context, {
                  "availability": availability,
                  "category": category,
                  "brands": selectedBrands.toList(),
                });
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Simpan",
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

  // TEMPLATE CHIP BUTTON
  Widget _chipButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: selected ? MyColors.secondary : Colors.white,
          border: Border.all(
            color: selected ? MyColors.secondary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
