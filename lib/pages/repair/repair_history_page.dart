// lib/pages/repair/repair_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/repair/repair_add_page.dart';
import 'package:flutter_kita/services/repair/repair_history_service.dart';
import 'package:flutter_kita/models/repair/repair_model.dart';
import 'widgets/repair_card.dart';
import 'widgets/repair_search_bar.dart';

class RepairHistoryPage extends StatefulWidget {
  const RepairHistoryPage({super.key});

  @override
  State<RepairHistoryPage> createState() => _RepairHistoryPageState();
}

class _RepairHistoryPageState extends State<RepairHistoryPage> {
  final TextEditingController _search = TextEditingController();
  final RepairHistoryService _historyService = RepairHistoryService();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF7F6F3);

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: RepairSearchBar(
                controller: _search,
                onChanged: () => setState(() {}),
              ),
            ),

            /// LIST
            Expanded(
              child: StreamBuilder<List<RepairModel>>(
                stream: _historyService.streamRepairs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada data'));
                  }

                  final repairs = snapshot.data!;
                  final q = _search.text.toLowerCase();

                  final filtered = repairs.where((r) {
                    return r.buyer.toLowerCase().contains(q) ||
                        r.product.toLowerCase().contains(q) ||
                        r.technician.toLowerCase().contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => RepairCard(model: filtered[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);

          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RepairAddPage()),
          );

          if (!mounted) return;

          if (res is Map && res['ok'] == true) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Data berhasil ditambahkan')),
            );
          }
        },
      ),
    );
  }
}
