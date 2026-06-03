import 'package:flutter/material.dart';
import 'package:flutter_kita/utils/formatters.dart';
import 'transaction_search_sheet.dart';

class CompleteRepairSheet extends StatefulWidget {
  final TextEditingController detailCtrl;
  final TextEditingController costCtrl;

  final String? transactionId;
  final String? transactionCode;

  final VoidCallback onSubmit;

  const CompleteRepairSheet({
    super.key,
    required this.detailCtrl,
    required this.costCtrl,
    required this.transactionId,
    required this.transactionCode,
    required this.onSubmit,
  });

  @override
  State<CompleteRepairSheet> createState() => _CompleteRepairSheetState();
}

class _CompleteRepairSheetState extends State<CompleteRepairSheet> {
  // String? _selectedTransactionId;
  Map<String, dynamic>? _selectedTransaction;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _openTransactionSelector() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TransactionSearchSheet(),
    );

    if (result == null) return;

    final summary = result['summary'] as Map<String, dynamic>? ?? {};

    setState(() {
      _selectedTransaction = result;

      widget.costCtrl.text = (summary['subtotal'] ?? 0).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),

              const Text(
                "Selesaikan Perbaikan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextField(
            controller: widget.detailCtrl,
            decoration: const InputDecoration(
              labelText: "Rincian Perbaikan",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          /// SUDAH ADA TRANSAKSI
          if (widget.transactionId != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biaya',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.transactionCode ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    Formatters.formatRupiah(
                      int.tryParse(widget.costCtrl.text) ?? 0,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ]
          /// BELUM ADA TRANSAKSI
          else ...[
            GestureDetector(
              onTap: _openTransactionSelector,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _selectedTransaction == null
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cari transaksi...'),
                          Icon(Icons.search),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTransaction!['summary']['txCode'],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            Formatters.formatRupiah(
                              _selectedTransaction!['summary']['subtotal'] ?? 0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onSubmit,
              child: const Text("Simpan & Tandai Selesai"),
            ),
          ),
        ],
      ),
    );
  }
}
