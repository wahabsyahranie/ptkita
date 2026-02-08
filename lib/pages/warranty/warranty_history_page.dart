import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/search_bar_widget.dart';

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

  void _setFilter(String v) => setState(() => _statusFilter = v);

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
            // SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchBarWidget(
                controller: _searchCtrl,
                hintText: 'Nama Pembeli / Produk / Serial',
                onChanged: (_) => setState(() {}),
              ),
            ),

            // FILTER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    active: _statusFilter == 'all',
                    onTap: () => _setFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Aktif',
                    active: _statusFilter == 'active',
                    onTap: () => _setFilter('active'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Non-Aktif',
                    active: _statusFilter == 'non',
                    onTap: () => _setFilter('non'),
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

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final buyer = (data['buyerName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final product = (data['productName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final serial = (data['serialNumber'] ?? '')
                        .toString()
                        .toLowerCase();

                    if (query.isNotEmpty &&
                        !buyer.contains(query) &&
                        !product.contains(query) &&
                        !serial.contains(query)) {
                      return false;
                    }

                    final isActive = data['isActive'] == true;
                    if (_statusFilter == 'active') return isActive;
                    if (_statusFilter == 'non') return !isActive;

                    return true;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = docs[i].data() as Map<String, dynamic>;

                      return _WarrantyCard(
                        buyer: d['buyerName'] ?? '-',
                        product: d['productName'] ?? '-',
                        warrantyType: _mapWarrantyType(
                          (d['warrantyType'] ?? '').toString(),
                        ),
                        isActive: d['isActive'] == true,
                        expireAt: d['expireAt'],
                      );
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? MyColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: MyColors.secondary),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : MyColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _WarrantyCard extends StatelessWidget {
  const _WarrantyCard({
    required this.buyer,
    required this.product,
    required this.warrantyType,
    required this.isActive,
    required this.expireAt,
  });

  final String buyer;
  final String product;
  final String warrantyType;
  final bool isActive;
  final dynamic expireAt;

  @override
  Widget build(BuildContext context) {
    final dateText = expireAt is Timestamp ? _fmtDate(expireAt.toDate()) : '-';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                _StatusBadge(active: isActive),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    buyer,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  dateText,
                  style: TextStyle(fontSize: 12, color: MyColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              warrantyType,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final bg = active ? const Color(0xFFDFF7E5) : const Color(0xFFFFF1E0);
    final fg = active ? const Color(0xFF1E8A3D) : const Color(0xFFB87112);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        active ? 'Aktif' : 'Non-Aktif',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
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

String _mapWarrantyType(String type) {
  switch (type.toLowerCase()) {
    case 'jasa':
    case 'service':
      return 'Garansi Servis Jasa';
    case 'sparepart':
      return 'Garansi Sparepart';
    case 'jasa & sparepart':
    case 'both':
      return 'Garansi Servis Jasa & Sparepart';
    default:
      return 'Garansi';
  }
}
