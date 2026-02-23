import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';
import 'package:flutter_kita/models/warranty_model.dart';
import 'warranty_detail_page.dart';

class WarrantyHistoryPage extends StatefulWidget {
  const WarrantyHistoryPage({super.key});

  @override
  State<WarrantyHistoryPage> createState() => _WarrantyHistoryPageState();
}

class _WarrantyHistoryPageState extends State<WarrantyHistoryPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _statusFilter = 'all'; // all | active | non

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _autoUpdateExpiredWarranty();
  }

  Future<void> _autoUpdateExpiredWarranty() async {
    final now = Timestamp.fromDate(DateTime.now());

    final snapshot = await FirebaseFirestore.instance
        .collection('warranty')
        .where('status', isEqualTo: 'Active')
        .where('expireAt', isLessThan: now)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'status': 'Expired'});
    }
  }

  Widget _buildFilterOption({
    required String label,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
  }) {
    final bool selected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? MyColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MyColors.secondary),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : MyColors.secondary,
          ),
        ),
      ),
    );
  }

  void _openFilterSheet() {
    String tempFilter = _statusFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: SizedBox(width: 40, child: Divider(thickness: 4)),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildFilterOption(
                        label: 'Semua',
                        value: 'all',
                        groupValue: tempFilter,
                        onChanged: (v) => setModalState(() => tempFilter = v),
                      ),
                      _buildFilterOption(
                        label: 'Aktif',
                        value: 'active',
                        groupValue: tempFilter,
                        onChanged: (v) => setModalState(() => tempFilter = v),
                      ),
                      _buildFilterOption(
                        label: 'Expired',
                        value: 'expired',
                        groupValue: tempFilter,
                        onChanged: (v) => setModalState(() => tempFilter = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() => _statusFilter = tempFilter);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        title: const Text('Data Garansi'),
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH & filter icon
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      controller: _searchCtrl,
                      hintText: 'Nama Pembeli / Produk',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: MyColors.secondary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.filter_alt,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('warranty')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada data garansi'));
                  }

                  final warranties = snapshot.data!.docs
                      .map((doc) => WarrantyModel.fromFirestore(doc))
                      .where((w) {
                        final buyer = w.buyerName.toLowerCase();
                        final product = w.productName.toLowerCase();
                        final serial = w.serialNumber.toLowerCase();

                        if (query.isNotEmpty &&
                            !buyer.contains(query) &&
                            !product.contains(query) &&
                            !serial.contains(query)) {
                          return false;
                        }

                        if (_statusFilter == 'active') return w.isReallyActive;
                        if (_statusFilter == 'expired') return w.isExpired;

                        return true;
                      })
                      .toList();

                  if (warranties.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: warranties.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final w = warranties[i];

                      return _WarrantyCard(warranty: w);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   UI COMPONENTS
   ========================= */

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({required this.warranty});
  final WarrantyModel warranty;

  @override
  Widget build(BuildContext context) {
    final dateText = _fmtDate(warranty.expireAt);

    late String statusText;
    late Color bg;
    late Color fg;

    if (warranty.isExpired) {
      statusText = 'Expired';
      bg = const Color(0xFFFFE5E5);
      fg = const Color(0xFFD32F2F);
    } else if (warranty.isReallyActive) {
      statusText = 'Aktif';
      bg = const Color(0xFFDFF7E5);
      fg = const Color(0xFF1E8A3D);
    } else {
      statusText = 'Non-Aktif';
      bg = const Color(0xFFFFF1E0);
      fg = const Color(0xFFB87112);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WarrantyDetailPage(warranty: warranty),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // NAMA PEMBELI
                  Expanded(
                    child: Text(
                      warranty.buyerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // TANGGAL EXPIRE
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 12, color: MyColors.secondary),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // NAMA PRODUK
              Text(
                warranty.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              // JENIS GARANSI
              Text(
                warranty.warrantyTypeLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
   HELPERS
   ========================= */

String _fmtDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
