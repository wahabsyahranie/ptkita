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
        _loadMore();
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
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _warranties.clear();

      _lastDoc = null;

      _hasMore = true;
    });

    await _loadMore();
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
    final query = _searchCtrl.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: MyColors.greySoft,

      appBar: AppBar(
        title: const Text('Data Garansi'),
        backgroundColor: MyColors.greySoft,
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
              onSearch: (_) => setState(() {}),
              onFilterTap: _openFilterSheet,
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _warranties.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    if (i < _warranties.length) {
                      final w = _warranties[i];

                      final buyer = w.buyerName.toLowerCase();
                      final product = w.productName.toLowerCase();
                      final serial = w.serialNumber.toLowerCase();

                      if (query.isNotEmpty &&
                          !buyer.contains(query) &&
                          !product.contains(query) &&
                          !serial.contains(query)) {
                        return const SizedBox();
                      }

                      if (_statusFilter == 'active' && !w.isActive) {
                        return const SizedBox();
                      }

                      if (_statusFilter == 'expired' && !w.isExpired) {
                        return const SizedBox();
                      }

                      return WarrantyCard(warranty: w);
                    }

                    if (_hasMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return const SizedBox();
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
