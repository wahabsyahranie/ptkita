// lib/pages/repair/repair_detail_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart';
import 'package:flutter_kita/styles/colors.dart';

class RepairDetailPage extends StatefulWidget {
  const RepairDetailPage({Key? key, required this.data, this.docId})
    : super(key: key);

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

  bool _saving = false;

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

  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    DateTime d;

    if (v is Timestamp) {
      d = v.toDate();
    } else if (v is DateTime) {
      d = v;
    } else {
      return v.toString();
    }

    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  String _fmtRupiah(int value) {
    final s = value.toString().split('').reversed.toList();
    final parts = <String>[];

    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }

    return 'Rp ${parts.reversed.join('.')}';
  }

  // ================= UPDATE STATUS =================

  Future<void> _markSelesaiWithRincian() async {
    if (_docId == null) return;

    final detail = _detailCtrl.text.trim();
    final costRaw = _costCtrl.text.trim();

    if (detail.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rincian wajib diisi')));
      return;
    }

    final digits = costRaw.replaceAll(RegExp(r'[^0-9]'), '');
    final costVal = int.tryParse(digits) ?? 0;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('repair').doc(_docId).update({
        'status': 'Selesai',
        'detailPart': detail,
        'cost': costVal,
        'completedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _current['status'] = 'Selesai';
        _current['detailPart'] = detail;
        _current['cost'] = costVal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perbaikan ditandai selesai')),
      );
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _markBelumSelesai() async {
    if (_docId == null) return;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance.collection('repair').doc(_docId).update({
        'status': 'Belum Selesai',
        'detailPart': FieldValue.delete(),
        'cost': FieldValue.delete(),
        'completedAt': FieldValue.delete(),
      });

      setState(() {
        _current['status'] = 'Belum Selesai';
        _current.remove('detailPart');
        _current.remove('cost');
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final buyer = _current['buyerName'] ?? '-';
    final item = _current['itemName'] ?? '-';
    final tech = _current['techName'] ?? '-';
    final phone = _current['noHp'] ?? '-';
    final dateText = _fmtDate(_current['date']);
    final completeness = _current['completeness'] ?? '-';
    final detailPart = _current['detailPart'] ?? '';
    final cost = _current['cost'];

    final warrantySnapshot = _current['warrantySnapshot'];

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
                  _badge('Garansi', Colors.blue.shade100, Colors.blue),

                const SizedBox(width: 8),

                _badge(
                  _isSelesai ? 'Selesai' : 'Belum Selesai',
                  _isSelesai ? Colors.green.shade100 : Colors.orange.shade100,
                  _isSelesai ? Colors.green : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // INFO CARD
            _card(
              Column(
                children: [
                  _row('Nama Pelanggan', buyer),
                  const DottedlineWidget(),
                  _row('Nama Barang', item),
                  const DottedlineWidget(),
                  _row('Teknisi', tech),
                  const DottedlineWidget(),
                  _row('Tanggal Masuk', dateText),
                  const DottedlineWidget(),
                  _row('No Whatsapps', phone),
                  const DottedlineWidget(),
                  _row('Kelengkapan', completeness),
                  const DottedlineWidget(),

                  // ================= WARRANTY SNAPSHOT =================
                  if (_isWarranty && warrantySnapshot != null) ...[
                    _row(
                      'Jenis Garansi',
                      warrantySnapshot['warrantyType'] ?? '-',
                    ),
                    const DottedlineWidget(),
                    _row(
                      'Klaim ke-',
                      ((warrantySnapshot['claimCountBefore'] ?? 0) + 1)
                          .toString(),
                    ),
                    const DottedlineWidget(),
                    _row(
                      'Berlaku Sampai',
                      _fmtDate(warrantySnapshot['expireAt']),
                    ),
                    const DottedlineWidget(),
                  ],

                  // ================= SELESAI INFO =================
                  if (_isSelesai) ...[
                    _row('Rincian', detailPart),
                    const SizedBox(height: 8),
                    _row(
                      'Biaya',
                      _isWarranty
                          ? 'Gratis (Garansi)'
                          : cost == null
                          ? '-'
                          : _fmtRupiah(cost),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
