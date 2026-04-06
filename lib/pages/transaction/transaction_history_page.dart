import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kita/pages/transaction/transaction_add_page.dart';
import 'package:flutter_kita/pages/transaction/transaction_detail_page.dart';
import 'package:flutter_kita/repositories/transaction/transaction_repository.dart';
import 'widgets/transaction_search_bar.dart';
import 'widgets/transaction_filter_sheet.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TextEditingController _search = TextEditingController();
  final TransactionRepository _repository = TransactionRepository();

  final List<DocumentSnapshot> _docs = [];
  List<DocumentSnapshot> _filteredDocs = [];
  final ScrollController _scroll = ScrollController();

  DocumentSnapshot? _lastDoc;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSearching = false;
  String _dateFilter = "all";

  // ignore: unused_field
  DateTime? _startDate;
  // ignore: unused_field
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _loadMore();

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final result = await _repository.getTransactions(
      lastDoc: _lastDoc,
      limit: 20,
    );

    final List<DocumentSnapshot> newDocs = result["data"];

    _lastDoc = result["lastDoc"];

    if (newDocs.length < 20) {
      _hasMore = false;
    }

    _docs.addAll(newDocs);
    _applyDateFilter();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
    });

    await _loadMore();
  }

  void _onSearchChanged() async {
    final query = _search.text.trim();

    if (query.isEmpty) {
      setState(() {
        _filteredDocs = List.from(_docs);
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    final ids = _repository.search(query);

    setState(() {
      _filteredDocs = _docs.where((doc) => ids.contains(doc.id)).toList();

      _isSearching = false;
    });
  }

  void _applyDateFilter() {
    final now = DateTime.now();

    if (_dateFilter == "all") {
      _filteredDocs = List.from(_docs);
      return;
    }

    if (_dateFilter == "today") {
      _filteredDocs = _docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();

        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }).toList();
    }

    if (_dateFilter == "7days") {
      final last7 = now.subtract(const Duration(days: 7));

      _filteredDocs = _docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();

        return date.isAfter(last7);
      }).toList();
    }

    if (_dateFilter == "30days") {
      final last30 = now.subtract(const Duration(days: 30));

      _filteredDocs = _docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();

        return date.isAfter(last30);
      }).toList();
    }

    if (_dateFilter == "custom" && _startDate != null && _endDate != null) {
      _filteredDocs = _docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();

        return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,

      appBar: AppBar(
        title: const Text('Data Transaksi'),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.secondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);

          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionAddPage()),
          );

          if (!mounted) return;

          if (res is Map && res['ok'] == true) {
            messenger.showSnackBar(const SnackBar(content: Text('Added!')));

            _refresh();
          }
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            /// SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TransactionSearchBar(
                      controller: _search,
                      onChanged: _onSearchChanged,
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// BUTTON FILTER
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return TransactionFilterSheet(
                            currentFilter: _dateFilter,
                            onApply: (value, start, end) {
                              setState(() {
                                _dateFilter = value;
                                _startDate = start;
                                _endDate = end;

                                _applyDateFilter(); // <-- ini yang bikin filter jalan
                              });
                            },
                          );
                        },
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

            /// LIST TRANSAKSI
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredDocs.isEmpty
                    ? const Center(
                        child: Text(
                          "Data tidak ditemukan",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: _filteredDocs.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _filteredDocs.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final data =
                              _filteredDocs[i].data() as Map<String, dynamic>;

                          return _TransactionCardFirestore(
                            data: data,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionDetailPage(
                                    data: data,
                                    transactionId: _docs[i].id,
                                  ),
                                ),
                              );
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

class _TransactionCardFirestore extends StatelessWidget {
  const _TransactionCardFirestore({required this.data, this.onTap});

  final VoidCallback? onTap;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final customer = data['customer'];
    final summary = data['summary'];
    final date = (data['date'] as Timestamp).toDate();

    final formattedDate = DateFormat('MMM d, y').format(date);

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
              /// STRIP
              Container(
                width: 6,
                height: 120,
                decoration: const BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              /// CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DATE + ICON
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: MyColors.secondary,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: MyColors.secondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// CUSTOMER
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

                      /// ITEM COUNT
                      Text(
                        '${summary['totalQty']} item dibeli',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// CODE + PRICE
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
                            style: const TextStyle(
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

  String _fmt(int v) {
    final s = v.toString().split('').reversed.toList();
    final parts = <String>[];

    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }

    return parts.reversed.join('.');
  }
}
