import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/warranty_model.dart';
import '../warranty/warranty_detail_page.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({
    super.key,
    required this.data,
    required this.transactionId,
  });

  final Map<String, dynamic> data;
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final customer = data['customer'] ?? {};
    final summary = data['summary'] ?? {};
    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final date = (data['date'] as Timestamp).toDate();
    final status = data['status'] ?? '—';

    final hasWarranty = items.any((i) => i['hasWarranty'] == true);

    Future<void> _openWarrantyList() async {
      final snap = await FirebaseFirestore.instance
          .collection('warranty')
          .where('transactionId', isEqualTo: transactionId)
          .get();

      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tidak ada data garansi')));
        return;
      }

      final warranties = snap.docs
          .map((d) => WarrantyModel.fromFirestore(d))
          .toList();

      // Jika cuma 1 → langsung buka detail
      if (warranties.length == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WarrantyDetailPage(warranty: warranties.first),
          ),
        );
        return;
      }

      // Jika lebih dari 1 → buka bottom sheet list
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _WarrantySelectionSheet(warranties: warranties),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: const Color(0xFFF7F6F3),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Header(txCode: summary['txCode'], status: status, date: date),
          const SizedBox(height: 16),

          _SectionCard(
            title: 'Pelanggan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Nama', customer['name']),
                _row('No HP', customer['phone']),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Item Dibeli',
            child: Column(
              children: items.map((item) {
                return _ItemRow(item: item);
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          _SectionCard(
            title: 'Ringkasan',
            child: Column(
              children: [
                _row('Total Item', '${summary['totalQty']}'),
                const Divider(),
                _row(
                  'Subtotal',
                  'Rp ${_fmt(summary['subtotal'])}',
                  isBold: true,
                ),
              ],
            ),
          ),

          if (hasWarranty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openWarrantyList,
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Lihat Detail Garansi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= HELPERS =================

  static Widget _row(String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Text(
            value ?? '—',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int v) {
    final s = v.toString().split('').reversed.toList();
    final parts = <String>[];
    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }
    return parts.reversed.join('.');
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.txCode,
    required this.status,
    required this.date,
  });

  final String? txCode;
  final String status;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            txCode ?? '—',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(
              color: status == 'Sudah Dibayar' ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final hasWarranty = item['hasWarranty'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['qty']} × Rp ${item['price']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (hasWarranty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Bergaransi',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'Rp ${item['subtotal']}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WarrantySelectionSheet extends StatelessWidget {
  const _WarrantySelectionSheet({required this.warranties});

  final List<WarrantyModel> warranties;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 40, child: Divider(thickness: 4)),
          const SizedBox(height: 16),
          const Text(
            "Pilih Garansi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            itemCount: warranties.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final w = warranties[i];

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.grey.shade100,
                title: Text(
                  w.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(w.buyerName),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WarrantyDetailPage(warranty: w),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
