import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/styles/colors.dart';
// import 'repair_form_page.dart'; // halaman form yang dibuat di bawah

class RepairHistoryPage extends StatefulWidget {
  const RepairHistoryPage({super.key});

  @override
  State<RepairHistoryPage> createState() => _RepairHistoryPageState();
}

class _RepairHistoryPageState extends State<RepairHistoryPage> {
  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _listenRepairs();
  }

  @override
  void dispose() {
    _search.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _listenRepairs() {
    // Jika beberapa dokumen lama belum punya 'createdAt', ubah query sesuai DB-mu.
    final col = FirebaseFirestore.instance
        .collection('repair')
        .orderBy('date', descending: true);

    _sub = col.snapshots().listen(
      (snap) {
        final docs = snap.docs.map((d) => _docToMap(d)).toList();
        setState(() {
          _items = docs;
          _loading = false;
        });
      },
      onError: (e) {
        debugPrint('Firestore listen error: $e');
        setState(() => _loading = false);
      },
    );
  }

  Map<String, dynamic> _docToMap(
    QueryDocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final data = d.data();

    final buyer = data['buyerName'] as String;
    final product = data['itemName'] as String;
    final tech = data['techName'] as String;
    final status = data['status'] as String;
    final warranty = data['warranty'] as bool;

    // DateTime dari Timestamp Firestore
    final timestamp = data['date'] as Timestamp;
    final date = timestamp.toDate();
    final dateText = _fmtShort(date);

    return {
      'id': d.id,
      'buyer': buyer,
      'product': product,
      'technician': tech,
      'status': status,
      'warranty': warranty,
      'date': date,
      'dateText': dateText,
      'raw': data,
    };
  }

  String _fmtShort(DateTime d) {
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

  Future<void> _onRefresh() async {
    // snapshot realtime sudah auto update; hanya beri sedikit delay untuk UX pull-to-refresh
    await Future.delayed(const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF7F6F3);
    final q = _search.text.trim().toLowerCase();
    final filtered = _items.where((e) {
      if (q.isNotEmpty) {
        final s =
            '${((e['buyer'] ?? '') as String).toLowerCase()} ${((e['product'] ?? '') as String).toLowerCase()} ${((e['technician'] ?? '') as String).toLowerCase()}';
        return s.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        title: const Text('Riwayat Perbaikan'),
        backgroundColor: pageBg,
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
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: _SearchBar(
                controller: _search,
                onChanged: () => setState(() {}),
              ),
            ),

            // list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _loading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 40),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 60),
                          Center(
                            child: Text(
                              'Tidak ada data. Tarik ke bawah untuk refresh.',
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _RepairCard(data: filtered[i]),
                      ),
              ),
            ),
          ],
        ),
      ),

      // floating add button -> buka form
      // floating add button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: aksi tambah perbaikan
        },
        backgroundColor: MyColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// small search bar widget (sama seperti kode kamu)
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

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
              controller: controller,
              onChanged: (_) => onChanged(),
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
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged();
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

/// Repair Card widget (sama seperti kode kamu, menerima Map data)
class _RepairCard extends StatelessWidget {
  const _RepairCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String;
    final hasGaransi = data['warranty'] as bool;
    final dateText = data['dateText'] as String;
    final buyer = data['buyer'] as String;
    final product = data['product'] as String;
    final tech = data['technician'] as String;

    final statusBg = status == 'Selesai'
        ? const Color(0xFFDFF7E5)
        : const Color(0xFFFFF1E0);
    final statusFg = status == 'Selesai'
        ? const Color(0xFF1E8A3D)
        : const Color(0xFFB87112);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // bisa ditambahkan navigasi ke detail (belakang)
        },
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.white,
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
                // top row: badges left, date right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusFg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // warranty badge
                    if (hasGaransi)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3FBFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Garansi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MyColors.secondary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // date
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 12,
                        color: MyColors.secondary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  buyer,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Diperbaiki Oleh $tech',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
