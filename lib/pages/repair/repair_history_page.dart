// lib/pages/repair/repair_history_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/repair/repair_add_page.dart';

// pastikan path ini sesuai lokasi file RepairDetailPage kamu
import 'repair_detail_page.dart';

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
    // cancel subscription first to avoid callbacks after dispose
    _sub?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _listenRepairs() {
    final col = FirebaseFirestore.instance
        .collection('repair')
        .orderBy('date', descending: true);

    _sub = col.snapshots().listen(
      (snap) {
        // safety: jangan setState jika widget sudah di-unmount
        if (!mounted) return;
        final docs = snap.docs.map((d) => _docToMap(d)).toList();
        setState(() {
          _items = docs;
          _loading = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        debugPrint('Firestore listen error: $e');
        setState(() => _loading = false);
      },
    );
  }

  Map<String, dynamic> _docToMap(
    QueryDocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final data = d.data();

    // defensif: ambil berbagai kemungkinan nama field
    final buyer = (data['buyerName'] ?? data['buyer'] ?? '-') as String;
    final product = (data['itemName'] ?? data['product'] ?? '-') as String;
    final tech = (data['techName'] ?? data['technician'] ?? '-') as String;
    final status = (data['status'] ?? '-') as String;
    // repairType used to determine "Garansi" badge
    final repairType =
        (data['repairType'] ?? data['repair_type'] ?? '') as String;

    // tanggal: ekspektasi field 'date' adalah Timestamp
    DateTime date = DateTime.now();
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      try {
        date = DateTime.parse(data['date'] as String);
      } catch (_) {}
    } else if (data['date'] is DateTime) {
      date = data['date'] as DateTime;
    }

    final dateText = _fmtShort(date);

    return {
      'id': d.id,
      'buyer': buyer,
      'product': product,
      'technician': tech,
      'status': status,
      'repairType': repairType,
      'date': date,
      'dateText': dateText,
      'raw': data, // simpan raw data supaya mudah dikirim ke detail
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
            // search bar (now Stateful, safer)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ambil messenger dulu (safely uses context synchronously)
          final messenger = ScaffoldMessenger.of(context);

          // buka page add (kamu bisa pakai const RepairAddPage() kalau ctor const)
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RepairAddPage()),
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
    );
  }
}

/// Search bar made Stateful to safely listen to controller
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
        border: Border.all(color: MyColors.secondary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: MyColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: (_) => widget.onChanged(),
              decoration: InputDecoration(
                hintText: 'Cari sesuatu',
                hintStyle: TextStyle(
                  color: MyColors.secondary.withValues(alpha: 0.6),
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
                color: MyColors.secondary.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

/// Repair Card widget
class _RepairCard extends StatelessWidget {
  const _RepairCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data['status'] as String? ?? '-';
    final dateText = data['dateText'] as String? ?? '-';
    final buyer = data['buyer'] as String? ?? '-';
    final product = data['product'] as String? ?? '-';
    final tech = data['technician'] as String? ?? '-';
    final repairType = (data['repairType'] ?? '') as String;

    // BARU: Logika badge garansi hanya berdasarkan repairType
    final repairTypeHasGaransi = repairType.toLowerCase().contains('garansi');
    final hasGaransi = repairTypeHasGaransi;

    final statusBg = status == 'Selesai'
        ? MyColors.success
        : MyColors.secondary;
    final statusFg = status == 'Selesai' ? MyColors.white : MyColors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final raw = data['raw'];
          final payload = raw != null
              ? Map<String, dynamic>.from(raw as Map)
              : Map<String, dynamic>.from(data);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepairDetailPage(
                data: payload,
                docId: data['id'], // ← INI tambahkan
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.white,
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
                    // warranty badge: now depends only on repairType
                    if (hasGaransi)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: MyColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1.8,
                            color: MyColors.success, // warna hijau terang
                          ),
                        ),
                        child: const Text(
                          'Garansi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: MyColors.success,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // date
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 12,
                        color: MyColors.secondary.withValues(alpha: 0.9),
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
                    color: Colors.black.withValues(alpha: 0.6),
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
