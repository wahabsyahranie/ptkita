// lib/pages/repair/repair_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/repair/repair_add_page.dart';
import 'package:flutter_kita/services/repair/repair_history_service.dart';
import 'package:flutter_kita/models/repair/repair_model.dart';
import 'package:flutter_kita/repositories/repair/repair_repository.dart';
import 'widgets/repair_card.dart';
import 'widgets/repair_search_bar.dart';
import 'widgets/repair_filter_sheet.dart';

class RepairHistoryPage extends StatefulWidget {
  const RepairHistoryPage({super.key});

  @override
  State<RepairHistoryPage> createState() => _RepairHistoryPageState();
}

class _RepairHistoryPageState extends State<RepairHistoryPage> {
  final TextEditingController _search = TextEditingController();
  final RepairRepository _repository = RepairRepository();
  late final RepairHistoryService _historyService = RepairHistoryService(
    _repository,
  );
  final ScrollController _scrollController = ScrollController();

  List<RepairModel> repairs = [];
  List<RepairModel> filteredRepairs = [];

  bool isLoading = false;
  bool isFirstLoad = true;
  bool _isSearching = false;

  /// filter state
  String filter = 'all';

  @override
  void initState() {
    super.initState();

    loadRepairs();

    _scrollController.addListener(() {
      /// JANGAN LOAD SAAT SEARCH AKTIF
      if (_search.text.trim().isNotEmpty) return;

      /// JANGAN LOAD SAAT MASIH SEARCHING
      if (_isSearching) return;

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        loadRepairs();
      }
    });
  }

  Future<void> loadRepairs({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      repairs.clear();
      filteredRepairs.clear();

      _search.clear();
    }

    setState(() {
      isLoading = true;

      if (refresh) {
        isFirstLoad = true;
      }
    });

    final data = await _historyService.fetchRepairs(refresh: refresh);

    setState(() {
      repairs.addAll(data);
      filteredRepairs = [...repairs];

      isLoading = false;
      isFirstLoad = false;
    });
  }

  void _onSearchChanged(String text) async {
    final query = text.trim();

    /// SEARCH KOSONG
    if (query.isEmpty) {
      if (!mounted) return;

      setState(() {
        filteredRepairs = [...repairs];
        _isSearching = false;
      });

      return;
    }

    setState(() {
      _isSearching = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    /// CEGAH SEARCH LAMA MENIMPA SEARCH BARU
    if (_search.text.trim() != query) return;

    final ids = _historyService.search(query);

    final results = repairs.where((r) {
      return ids.contains(r.id);
    }).toList();

    if (!mounted) return;

    setState(() {
      filteredRepairs = results;
      _isSearching = false;
    });
  }
  // print("IDS: $ids");
  //   print("REPAIRS: ${repairs.map((e) => e.id)}");

  @override
  void dispose() {
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredRepairs.where((r) {
      if (filter == 'done' && r.status != 'Selesai') {
        return false;
      }

      if (filter == 'pending' && r.status == 'Selesai') {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text('Riwayat Perbaikan'),
        backgroundColor: MyColors.white,
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
            /// SEARCH + FILTER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: RepairSearchBar(
                      controller: _search,
                      onChanged: (text) => _onSearchChanged(text),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// FILTER BUTTON
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => RepairFilterSheet(
                          currentFilter: filter,
                          onApply: (value) {
                            setState(() {
                              filter = value;
                            });
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: MyColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.filter_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => loadRepairs(refresh: true),
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : isFirstLoad
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount:
                            filtered.length +
                            (_historyService.hasMore && _search.text.isEmpty
                                ? 1
                                : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          if (i < filtered.length) {
                            return RepairCard(
                              model: filtered[i],
                              onUpdated: () {
                                loadRepairs(refresh: true);
                              },
                            );
                          }

                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
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

            loadRepairs(refresh: true);
          }
        },
      ),
    );
  }
}
