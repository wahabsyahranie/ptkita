import 'package:flutter/material.dart';
import 'package:flutter_kita/core/widgets/confirmation_sheet.dart';
import 'package:flutter_kita/pages/inventory/add_edit_inventory_page.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';
import 'package:flutter_kita/repositories/user/firestore_user_repository.dart';
import 'package:flutter_kita/services/user/user_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';

class DetailsInventoryPage extends StatefulWidget {
  final String itemId;

  const DetailsInventoryPage({super.key, required this.itemId});

  @override
  State<DetailsInventoryPage> createState() => _DetailsInventoryPageState();
}

class _DetailsInventoryPageState extends State<DetailsInventoryPage> {
  late final InventoryService _service;
  @override
  void initState() {
    super.initState();
    _service = InventoryService(
      FirestoreInventoryRepository(),
      UserService(FirestoreUserRepository()),
    );
  }

  /// Membatasi text
  String limitText(String text, int max) {
    return text.length <= max ? text : "${text.substring(0, max)}...";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Item?>(
      stream: _service.streamItemById(widget.itemId),
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
                icon: const Icon(Icons.edit, color: MyColors.white),
              ),

              /// DELETE
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: MyColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => ConfirmationSheet(
                      title: "Hapus item?",
                      description: "Item akan dihapus permanen.",
                      confirmText: "Hapus",
                      isDestructive: true,
                      onConfirm: () async {
                        await _service.deleteItem(item.id!);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.delete, color: MyColors.white),
              ),
            ],
          ),

          body: SafeArea(child: _buildContent(item)),
        );
      },
    );
  }

  Widget _buildContent(Item item) {
    final name = item.name ?? '-';
    final sku = item.sku ?? '-';
    final price = item.price ?? 0;
    final stock = item.stock ?? 0;
    final category = item.category ?? '-';
    final desc = item.description ?? '-';
    final imageProvider = _service.resolveImage(item);
    final merk = item.merk ?? '-';
    final locationCode = item.locationCode ?? '-';
    final movementLabel = _service.getMovementLabel(item);
    final movementColor = _service.getMovementColor(item);
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
                    child: Image(
                      image: imageProvider,
                      width: 230,
                      height: 230,
                      fit: BoxFit.contain, // sarankan contain untuk logo
                    ),
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

                _rowInfo("Harga", _service.formatCurrency(price)),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("SKU", sku),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Stok", stock.toString()),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Kategori", category),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Merk", merk),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowInfo("Rak", locationCode),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                _rowMovement("Movement Speed", movementLabel, movementColor),
                const DottedlineWidget(),
                const SizedBox(height: 10),

                const Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(desc),
                const DottedlineWidget(),

                const SizedBox(height: 16),

                // const Divider(height: 24, thickness: 0.6),
                _buildAuditSection(item),

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

  Widget _rowMovement(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  ////  METHOD AUDIT
  Widget _buildAuditSection(Item item) {
    final createdBy = item.createdByName ?? '-';
    final createdAt = item.createdAt;
    final editedBy = item.lastEditedByName ?? '-';
    final editedAt = item.lastEditedAt;

    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return "${date.day.toString().padLeft(2, '0')} "
          "${_monthName(date.month)} "
          "${date.year}, "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 10),
      title: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.black54),
          SizedBox(width: 6),
          Text(
            "Informasi Sistem",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      iconColor: Colors.black54,
      collapsedIconColor: Colors.black54,
      children: [
        const SizedBox(height: 8),
        _buildAuditRow("Dibuat oleh", createdBy),
        const SizedBox(height: 6),
        _buildAuditRow("Dibuat pada", formatDate(createdAt)),
        const SizedBox(height: 10),
        _buildAuditRow("Terakhir diubah", editedBy),
        const SizedBox(height: 6),
        _buildAuditRow("Waktu perubahan", formatDate(editedAt)),
      ],
    );
  }

  //// HELPER ROW KHUSUS AUDIT
  Widget _buildAuditRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  //// HELPER BULAN UNTUK AUDIT
  String _monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[month];
  }
}
