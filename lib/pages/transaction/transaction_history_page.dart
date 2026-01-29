import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/pages/transaction/transaction_add_page.dart';
import 'package:flutter_kita/pages/transaction/transaction_detail_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        title: const Text('Data Transaksi'),
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ambil messenger dulu (safely uses context synchronously)
          final messenger = ScaffoldMessenger.of(context);

          // buka page add (kamu bisa pakai const RepairAddPage() kalau ctor const)
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TransactionAddPage()),
          );

          // widget mungkin sudah di-unmount setelah await -> aman cek mounted
          if (!mounted) return;

          if (res is Map && res['ok'] == true) {
            messenger.showSnackBar(const SnackBar(content: Text('Added!')));
          }
        },
        backgroundColor: MyColors.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔍 SEARCH BAR (SAMA PERSIS DENGAN RepairHistoryPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: _SearchBar(
                controller: _search,
                onChanged: () => setState(() {}),
              ),
            ),

            /// LIST TRANSAKSI
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transaction')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada transaksi'));
                  }

                  final q = _search.text.toLowerCase();

                  final docs = snapshot.data!.docs.where((doc) {
                    if (q.isEmpty) return true;

                    final data = doc.data() as Map<String, dynamic>;
                    final customer = data['customer'] ?? {};
                    final summary = data['summary'] ?? {};

                    return [
                      customer['name'],
                      customer['phone'],
                      summary['txCode'],
                    ].whereType<String>().join(' ').toLowerCase().contains(q);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return _TransactionCardFirestore(
                        data: data,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailPage(data: data),
                            ),
                          );
                        },
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

/// =======================
/// SEARCH BAR (IDENTIK)
/// =======================
class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  void _listener() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: MyColors.secondary.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: MyColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: (_) => widget.onChanged(),
              decoration: InputDecoration(
                hintText: 'Cari sesuatu',
                hintStyle: TextStyle(
                  color: MyColors.secondary.withOpacity(0.6),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onChanged();
              },
              child: Icon(
                Icons.close_rounded,
                color: MyColors.secondary.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }
}

/// =======================
/// TRANSACTION CARD
/// =======================
class _TransactionCardFirestore extends StatelessWidget {
  const _TransactionCardFirestore({required this.data, this.onTap});
  final VoidCallback? onTap;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final customer = data['customer'];
    final summary = data['summary'];
    final date = (data['date'] as Timestamp).toDate();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              // STRIP KIRI
              Container(
                width: 6,
                height: 120,
                decoration: BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        customer['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${summary['totalQty']} item dibeli',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              summary['txCode'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          Text(
                            'Rp ${_fmt(summary['subtotal'])}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: MyColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FORMAT RUPIAH
  String _fmt(int v) {
    final s = v.toString().split('').reversed.toList();
    final parts = <String>[];
    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }
    return parts.reversed.join('.');
  }
}
