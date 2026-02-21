import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';

class DetailsInventoryPage extends StatefulWidget {
  final String itemId;
  final InventoryService service;

  const DetailsInventoryPage({
    super.key,
    required this.itemId,
    required this.service,
  });

  @override
  State<DetailsInventoryPage> createState() => _DetailsInventoryPageState();
}

class _DetailsInventoryPageState extends State<DetailsInventoryPage> {
  @override
  void initState() {
    super.initState();
  }

  /// Membatasi text
  String limitText(String text, int max) {
    return text.length <= max ? text : "${text.substring(0, max)}...";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Item?>(
      stream: widget.service.streamItemById(widget.itemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: MyColors.secondary),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Terjadi kesalahan")));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Item tidak ditemukan")),
          );
        }

        final item = snapshot.data!;

        return Scaffold(
          backgroundColor: MyColors.white,

          appBar: AppBar(
            title: const Text('Detail Barang'),
            backgroundColor: MyColors.secondary,
            surfaceTintColor: Colors.transparent,
            actions: [
              /// EDIT
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditInventoryPage(item: item),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),

              /// DELETE
              IconButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: MyColors.white,
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

                  if (ok == true) {
                    await widget.service.deleteItem(item);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),

          body: _buildContent(item),
        );
      },
    );
  }

  Widget _buildContent(Item item) {
    final service = InventoryService(FirestoreInventoryRepository());
    final name = item.name ?? '-';
    final sku = item.sku ?? '-';
    final price = item.price ?? 0;
    final stock = item.stock ?? 0;
    final type = item.type ?? '-';
    final desc = item.description ?? '-';
    final imageUrl = item.imageUrl;
    final merk = item.merk ?? '-';
    final locationCode = item.locationCode ?? '-';
    return SingleChildScrollView(
      child: Column(
        children: [
          // ======== TOP IMAGE ========
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
                      color: MyColors.black.withValues(alpha: 0.2),
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
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 230,
                            height: 230,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          )
                        : _placeholder(),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      limitText(name, 30),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: MyColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ========= BODY DETAIL =========
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowInfo("Nama", limitText(name, 45)),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Harga", service.formatCurrency(price)),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("SKU", sku),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Stok", stock.toString()),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Type", type),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Merk", merk),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Rak", locationCode),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                const Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(desc),
                const DottedlineWidget(),

                const SizedBox(height: 30),

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
    );
  }

  /// Row reusable
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
      color: MyColors.greySoft,
      child: const Center(
        child: Icon(Icons.image, size: 60, color: MyColors.black),
      ),
    );
  }
}
