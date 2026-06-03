import 'package:flutter_kita/core/search/search_engine.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:intl/intl.dart';

class TransactionSearchSheet extends StatefulWidget {
  const TransactionSearchSheet({super.key});

  @override
  State<TransactionSearchSheet> createState() => _TransactionSearchSheetState();
}

class _TransactionSearchSheetState extends State<TransactionSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final InvertedIndex _searchEngine = InvertedIndex();

  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          children: [
            /// HANDLE
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// TITLE
            const Text(
              'Pilih Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// SEARCH
            Container(
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MyColors.secondary),
              ),
              child: TextField(
                controller: _searchCtrl,
                cursorColor: MyColors.secondary,
                decoration: InputDecoration(
                  hintText: 'Cari kode transaksi / pelanggan',
                  hintStyle: TextStyle(
                    color: MyColors.secondary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: MyColors.secondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                onChanged: (_) {
                  _debounce?.cancel();

                  _debounce = Timer(const Duration(milliseconds: 200), () {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transaction')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  _searchEngine.clear();

                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    final customer = data['customer'] as Map<String, dynamic>?;

                    final summary = data['summary'] as Map<String, dynamic>?;

                    _searchEngine.addDocument(
                      doc.id,
                      [
                        customer?['name'],
                        summary?['txCode'],
                      ].whereType<String>().toList(),
                    );
                  }

                  final query = _searchCtrl.text.trim().toLowerCase();

                  final ids = query.isEmpty
                      ? docs.map((e) => e.id).toSet()
                      : _searchEngine.search(query);

                  final results = docs.where((doc) {
                    return ids.contains(doc.id);
                  }).toList();

                  if (results.isEmpty) {
                    return const Center(child: Text('Tidak ditemukan'));
                  }

                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final doc = results[index];

                      final data = doc.data() as Map<String, dynamic>;

                      final customer =
                          data['customer'] as Map<String, dynamic>?;

                      final summary = data['summary'] as Map<String, dynamic>?;

                      final items = data['items'] as List<dynamic>? ?? [];

                      final serviceFee = summary?['serviceFee'] ?? 0;

                      final partCost = items.fold<int>(
                        0,
                        (totalPart, item) =>
                            totalPart + ((item['subtotal'] ?? 0) as int),
                      );

                      final total = summary?['subtotal'] ?? 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),

                        title: Text(
                          '${summary?['txCode'] ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer?['name'] ?? '-'),

                            const SizedBox(height: 6),

                            Text(
                              'Jasa : Rp ${NumberFormat.decimalPattern('id_ID').format(serviceFee)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),

                            Text(
                              'Part : Rp ${NumberFormat.decimalPattern('id_ID').format(partCost)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),

                            Text(
                              'Total : Rp ${NumberFormat.decimalPattern('id_ID').format(total)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        onTap: () {
                          Navigator.pop(context, {'id': doc.id, ...data});
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
