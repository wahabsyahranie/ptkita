import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/warranty/warranty_add_page.dart';
import 'package:flutter_kita/models/warranty/warranty_model.dart';
import 'package:flutter_kita/repositories/warranty/warranty_repository.dart';
import 'widgets/warranty_search_section.dart';
import 'widgets/warranty_filter_sheet.dart';
import 'widgets/warranty_card.dart';

class WarrantyHistoryPage extends StatefulWidget {
  const WarrantyHistoryPage({super.key});

  @override
  State<WarrantyHistoryPage> createState() => _WarrantyHistoryPageState();
}

class _WarrantyHistoryPageState extends State<WarrantyHistoryPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  final WarrantyRepository _repository = WarrantyRepository();

  final List<WarrantyModel> _warranties = [];
  List<WarrantyModel> _filteredWarranties = [];

  DocumentSnapshot? _lastDoc;

  bool _isLoading = false;
  bool _hasMore = true;

  final int _limit = 10;

  String _statusFilter = 'all';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final result = await _repository.getWarranties(
      lastDoc: _lastDoc,
      limit: _limit,
    );

    final List<WarrantyModel> newData = result["data"];

    _lastDoc = result["lastDoc"];

    if (newData.length < _limit) {
      _hasMore = false;
    }

    setState(() {
      _warranties.addAll(newData);
      _filteredWarranties = List.from(_warranties);
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _warranties.clear();
      _lastDoc = null;
      _hasMore = true;
      _isLoading = false;
    });

    await _loadMore();
  }

  void _onSearchChanged(String text) async {
    final query = text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredWarranties = List.from(_warranties);
      });
      return;
    }

    final ids = _repository.search(query);

    setState(() {
      _filteredWarranties = _warranties
          .where((w) => ids.contains(w.id))
          .toList();
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return WarrantyFilterSheet(
          currentFilter: _statusFilter,
          onApply: (val) {
            setState(() {
              _statusFilter = val;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,

      appBar: AppBar(
        title: const Text('Data Garansi'),
        backgroundColor: MyColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: MyColors.black),
        titleTextStyle: const TextStyle(
          color: MyColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // FAB TAMBAH WARRANTY
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);

          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WarrantyAddPage()),
          );

          if (!mounted) return;

          if (res is Map && res['ok'] == true) {
            messenger.showSnackBar(
              const SnackBar(content: Text("Warranty berhasil ditambahkan")),
            );

            _refresh();
          }
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            WarrantySearchSection(
              controller: _searchCtrl,
              onSearch: _onSearchChanged,
              onFilterTap: _openFilterSheet,
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: Builder(
                  builder: (context) {
                    List<WarrantyModel> displayList = _filteredWarranties;

                    if (_statusFilter == 'active') {
                      displayList = displayList
                          .where((w) => w.isActive)
                          .toList();
                    }

                    if (_statusFilter == 'expired') {
                      displayList = displayList
                          .where((w) => w.isExpired)
                          .toList();
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _searchCtrl.text.isEmpty
                          ? displayList.length + 1
                          : displayList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        if (i < displayList.length) {
                          final w = displayList[i];
                          return WarrantyCard(warranty: w);
                        }

                        if (_searchCtrl.text.isEmpty && _hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return const SizedBox();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
