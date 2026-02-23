import 'package:flutter/material.dart';
import 'widgets/repair_detail_card.dart';
import 'package:flutter_kita/services/repair/repair_service.dart';
import 'widgets/repair_status_badge.dart';
import 'package:flutter_kita/utils/formatters.dart';

class RepairDetailPage extends StatefulWidget {
  const RepairDetailPage({super.key, required this.data, this.docId});

  final Map<String, dynamic> data;
  final String? docId;

  @override
  State<RepairDetailPage> createState() => _RepairDetailPageState();
}

class _RepairDetailPageState extends State<RepairDetailPage> {
  late Map<String, dynamic> _current;
  late String? _docId;

  final TextEditingController _detailCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();

  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _current = Map<String, dynamic>.from(widget.data);
    _docId = widget.docId ?? widget.data['id'];

    _detailCtrl.text = (_current['detailPart'] ?? '').toString();
    _costCtrl.text = (_current['cost'] ?? '').toString();
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  // ================= HELPERS =================

  bool get _isSelesai =>
      (_current['status'] ?? '').toString().toLowerCase() == 'selesai';

  bool get _isWarranty => (_current['repairCategory'] ?? '') == 'warranty';

  // ================= UPDATE STATUS =================

  Future<void> _markSelesai() async {
    if (_docId == null) return;

    final detail = _detailCtrl.text.trim();
    final costRaw = _costCtrl.text.trim();

    if (detail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rincian wajib diisi')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text(
          "Setelah ditandai selesai, data tidak bisa diedit.\n\nLanjutkan?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final digits = costRaw.replaceAll(RegExp(r'[^0-9]'), '');
    final costVal = int.tryParse(digits) ?? 0;

    try {
      final result = await RepairService.markSelesai(
        docId: _docId!,
        detail: detail,
        cost: costVal,
      );

      if (!mounted) return;

      setState(() {
        _current['status'] = 'Selesai';
        _current['detailPart'] = detail;
        _current['cost'] = costVal;
        _current['completedByName'] = result['completedByName'];
        _current['completedAt'] = result['completedAt'];
        _showForm = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perbaikan berhasil diselesaikan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat menyimpan data')),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final dateText = Formatters.formatDate(_current['date']);

    final detailPart = _current['detailPart'] ?? '';
    final cost = _current['cost'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Perbaikan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F6F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // STATUS BADGE
            Row(
              children: [
                if (_isWarranty)
                  const RepairStatusBadge(
                    text: 'Garansi',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                  ),

                const SizedBox(width: 8),

                RepairStatusBadge(
                  text: _isSelesai ? 'Selesai' : 'Belum Selesai',
                  backgroundColor: _isSelesai ? Colors.green : Colors.orange,
                  textColor: Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // INFO CARD
            RepairDetailCard(
              data: _current,
              isSelesai: _isSelesai,
              isWarranty: _isWarranty,
              dateText: dateText,
              detailPart: detailPart,
              cost: cost,
              bottomSection: !_isSelesai
                  ? Column(
                      children: [
                        if (!_showForm)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showForm = true;
                                });
                              },
                              child: const Text("Tandai Selesai"),
                            ),
                          ),

                        if (_showForm) ...[
                          const SizedBox(height: 16),

                          TextField(
                            controller: _detailCtrl,
                            decoration: const InputDecoration(
                              labelText: "Rincian Perbaikan",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),

                          const SizedBox(height: 12),

                          if (!_isWarranty)
                            TextField(
                              controller: _costCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Biaya",
                                prefixText: "Rp ",
                                border: OutlineInputBorder(),
                              ),
                            ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _markSelesai,
                              child: const Text("Simpan & Tandai Selesai"),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showForm = false;
                              });
                            },
                            child: const Text("Batal"),
                          ),
                        ],
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
