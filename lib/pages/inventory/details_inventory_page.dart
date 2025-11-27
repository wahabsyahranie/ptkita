import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsInventoryPage extends StatelessWidget {
  final Item? item;

  const DetailsInventoryPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Firestore values
    final name = item?.name ?? '-';
    final sku = item?.sku ?? '-';
    final price = item?.price ?? 0;
    final stock = item?.stock ?? 0;
    final type = item?.type ?? '-';
    final desc = item?.description ?? '-';
    final imageUrl = item?.imageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: MyColors.secondary,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.edit, color: MyColors.secondary),
            ),
          ),

          // Delete
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus item?'),
                    content: const Text('Item akan dihapus permanen.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (ok == true && item?.id != null) {
                  await FirebaseFirestore.instance
                      .collection('items')
                      .doc(item!.id)
                      .delete();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item dihapus')),
                    );
                    Navigator.of(context).pop();
                  }
                }
              },
              icon: Container(
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.delete, color: MyColors.secondary),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP BANNER WITH IMAGE
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MyColors.secondary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 230,
                              height: 230,
                              fit: BoxFit.cover,
                            )
                          : _placeholder(), // fallback
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: MyColors.background,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CONTENT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA
                  _rowInfo("Nama", name),
                  const DottedlineWidget(),
                  const SizedBox(height: 10),

                  // HARGA
                  _rowInfo("Harga", "Rp $price"),
                  const DottedlineWidget(),
                  const SizedBox(height: 10),

                  // SKU
                  _rowInfo("SKU", sku),
                  const DottedlineWidget(),
                  const SizedBox(height: 10),

                  // STOK
                  _rowInfo("Stok", stock.toString()),
                  const DottedlineWidget(),
                  const SizedBox(height: 10),

                  // TYPE
                  _rowInfo("Type", type),
                  const DottedlineWidget(),
                  const SizedBox(height: 10),

                  // DESKRIPSI
                  const Text(
                    "Deskripsi",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(desc),
                  const DottedlineWidget(),

                  const SizedBox(height: 30),

                  // CLOSE BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: MyColors.secondary,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Tutup",
                        style: TextStyle(
                          fontSize: 18,
                          color: MyColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Row for simple key-value
  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        Text(value),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 230,
      height: 230,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.black26),
      ),
    );
  }
}
