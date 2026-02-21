import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';

class DetailsInventoryPage extends StatefulWidget {
  final Item? item;
  const DetailsInventoryPage({super.key, required this.item});

  @override
  State<DetailsInventoryPage> createState() => _DetailsInventoryPageState();
}

class _DetailsInventoryPageState extends State<DetailsInventoryPage> {
  Item? _item;
  bool _loading = false;
  late final InventoryService _service;

  @override
  void initState() {
    super.initState();
    _item = widget.item;

    _service = InventoryService(FirestoreInventoryRepository());
  }

  /// 🔄 Fetch ulang data terbaru dari Firestore
  Future<void> _refreshItem() async {
    if (_item == null || _item!.id == null) return;

    setState(() => _loading = true);

    final fresh = await _service.getItemById(_item!.id!);

    if (!mounted) return;

    setState(() {
      _item = fresh;
      _loading = false;
    });
  }

  /// Membatasi text
  String limitText(String text, int max) {
    return text.length <= max ? text : "${text.substring(0, max)}...";
  }

  @override
  Widget build(BuildContext context) {
    // data Firestore setelah refresh
    final name = _item?.name ?? '-';
    final sku = _item?.sku ?? '-';
    final price = _item?.price ?? 0;
    final stock = _item?.stock ?? 0;
    final type = _item?.type ?? '-';
    final desc = _item?.description ?? '-';
    final imageUrl = _item?.imageUrl;
    final merk = _item?.merk ?? '-';
    final locationCode = _item?.locationCode ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Barang'),
        backgroundColor: MyColors.secondary,
        surfaceTintColor: Colors.transparent,
        actions: [
          /// ============================
          ///          EDIT BUTTON
          /// ============================
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditInventoryPage(item: _item),
                ),
              );

              // jika halaman AddEdit return true → refresh
              if (result == true) {
                await _refreshItem();
              }
            },
            icon: Container(
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.edit, color: MyColors.secondary),
            ),
          ),

          /// ============================
          ///          DELETE BUTTON
          /// ============================
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
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
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: MyColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            color: MyColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (ok == true && _item?.id != null) {
                  await _service.deleteItem(_item!);

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

      backgroundColor: MyColors.white,

      /// Loading indicator kecil di bawah AppBar
      body: Stack(
        children: [
          _buildContent(
            name,
            sku,
            price,
            stock,
            type,
            desc,
            imageUrl,
            merk,
            locationCode,
          ),

          if (_loading)
            Container(
              color: MyColors.white.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: MyColors.secondary),
              ),
            ),
        ],
      ),
    );
  }

  //RUPIAH FORMATTER
  static final NumberFormat _rupiahFormatter = NumberFormat('#,###', 'id_ID');

  Widget _buildContent(
    String name,
    String sku,
    num price,
    int stock,
    String type,
    String desc,
    String? imageUrl,
    String merk,
    String locationCode,
  ) {
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
                        ? Image.network(
                            imageUrl,
                            width: 230,
                            height: 230,
                            fit: BoxFit.cover,
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

                _rowInfo("Harga", "Rp ${_rupiahFormatter.format(price)}"),
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
