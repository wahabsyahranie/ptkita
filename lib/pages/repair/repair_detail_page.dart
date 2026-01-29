// lib/pages/repair/repair_detail_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/widget/dottedline_widget.dart'; // atau path yang sesuai
import 'package:flutter_kita/styles/colors.dart';

class RepairDetailPage extends StatefulWidget {
  /// [data] = map berisi fields dari Firestore (contoh: buyerName, itemName, techName, date, noHp, repairType, detailPart, cost, status)
  /// [docId] = optional, id dokumen Firestore untuk update; jika tidak ada, update akan gagal.
  const RepairDetailPage({Key? key, required this.data, this.docId})
    : super(key: key);

  final Map<String, dynamic> data;
  final String? docId;

  @override
  State<RepairDetailPage> createState() => _RepairDetailPageState();
}

class _RepairDetailPageState extends State<RepairDetailPage> {
  late Map<String, dynamic>
  _current; // local copy (tidak otomatis update Firestore)
  late String? _docId;

  // controllers for editable fields (detailPart & cost)
  final TextEditingController _detailCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _current = Map<String, dynamic>.from(widget.data);
    _docId = widget.docId ?? widget.data['id'] ?? widget.data['docId'];

    // initialize controllers with existing values (if any)
    _detailCtrl.text =
        (_current['detailPart'] ?? _current['detailpart'] ?? '') as String;
    _costCtrl.text =
        (_current['cost'] ?? _current['price'] ?? '')?.toString() ?? '';
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  // helper: format timestamp or string -> human readable
  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    DateTime d;
    if (v is Timestamp)
      d = v.toDate();
    else if (v is DateTime)
      d = v;
    else {
      try {
        d = DateTime.parse(v.toString());
      } catch (_) {
        return v.toString();
      }
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

  String _fmtRupiah(String raw) {
    // raw mungkin "250000" atau "250.000", kita ambil angka saja
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Rp 0';
    final val = int.tryParse(digits) ?? 0;
    final s = val.toString().split('').reversed.toList();
    final parts = <String>[];
    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }
    return 'Rp ${parts.reversed.join('.')}';
  }

  bool get _isSelesai {
    final s = (_current['status'] ?? '').toString().toLowerCase();
    return s == 'selesai' || s == 'done' || s == 'finished';
  }

  bool get _hasGaransi {
    final repairType = (_current['repairType'] ?? _current['repair_type'] ?? '')
        .toString();
    return repairType.toLowerCase().contains('garansi');
  }

  Future<void> _showActionMenu() async {
    // options depend on status
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  _isSelesai ? 'Edit Rincian' : 'Tandai Perbaikan Selesai',
                ),
                onTap: () => Navigator.pop(ctx, 'selesai'),
              ),
              ListTile(
                title: const Text('Tandai Perbaikan Belum Selesai'),
                onTap: () => Navigator.pop(ctx, 'belum'),
              ),
            ],
          ),
        );
      },
    );

    if (choice == null) return;
    if (choice == 'selesai') {
      // open form to enter/edit detailPart & cost
      await _openEditRincianSheet();
    } else if (choice == 'belum') {
      await _markBelumSelesai();
    }
  }

  Future<void> _openEditRincianSheet() async {
    // prefilled already in controllers
    final ok = await showModalBottomSheet<bool>(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Konfirmasi Tindakan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detailCtrl,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      label: 'Rincian (Penggantian Sparepart)',
                      hint: 'Contoh: 1. rantai, 2. Busi',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _costCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'Biaya Perbaikan',
                      prefix: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.secondary,
                            foregroundColor: MyColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (ok == true) {
      await _markSelesaiWithRincian();
    }
  }

  Future<void> _markSelesaiWithRincian() async {
    if (_docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengupdate: document id tidak tersedia.'),
        ),
      );
      return;
    }

    final detail = _detailCtrl.text.trim();
    final costRaw = _costCtrl.text.trim();
    if (detail.isEmpty || costRaw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rincian dan biaya wajib diisi.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // convert cost to int (safe)
      final digits = costRaw.replaceAll(RegExp(r'[^0-9]'), '');
      final costVal = int.tryParse(digits) ?? 0;

      await FirebaseFirestore.instance.collection('repair').doc(_docId).update({
        'status': 'Selesai',
        'detailPart': detail,
        'cost': costVal
            .toString(), // sesuai DB-mu (string) — ubah ke int jika perlu
        'completedAt': FieldValue.serverTimestamp(),
      });

      // update local view
      setState(() {
        _current['status'] = 'Selesai';
        _current['detailPart'] = detail;
        _current['cost'] = costVal.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perbaikan ditandai selesai.')),
      );
    } catch (e) {
      debugPrint('update error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _markBelumSelesai() async {
    if (_docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengupdate: document id tidak tersedia.'),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Tandai perbaikan sebagai belum selesai? Ini akan menghapus rincian & biaya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, lanjut'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _saving = true);
    try {
      // update: set status, remove detailPart & cost
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perbaikan ditandai belum selesai.')),
      );
    } catch (e) {
      debugPrint('update error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengupdate status.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyer = _current['buyerName'] ?? _current['buyer'] ?? '-';
    final item = _current['itemName'] ?? _current['item'] ?? '-';
    final tech = _current['techName'] ?? _current['tech'] ?? '-';
    final dateText = _fmtDate(_current['date']);
    final phone =
        _current['noHp'] ?? _current['nohp'] ?? _current['phone'] ?? '-';
    final repairType = _current['repairType'] ?? _current['repair_type'] ?? '-';
    final detailPart = _current['detailPart'] ?? _current['detailpart'] ?? '';
    final cost = _current['cost'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Perbaikan'),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // action menu button (visible always)
          IconButton(
            onPressed: _saving ? null : _showActionMenu,
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // small badges under banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  if (_hasGaransi)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3FBFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Garansi',
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isSelesai
                          ? const Color(0xFFDFF7E5)
                          : const Color(0xFFFFF1E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isSelesai ? 'Selesai' : 'Belum Selesai',
                      style: TextStyle(
                        color: _isSelesai
                            ? const Color(0xFF1E8A3D)
                            : const Color(0xFFB87112),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // content
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  _infoRow('Nama Pelanggan', buyer),
                  const DottedlineWidget(),
                  _infoRow('Nama Barang', item),
                  const DottedlineWidget(),
                  _infoRow('Teknisi', tech),
                  const DottedlineWidget(),
                  _infoRow('Tanggal Masuk', dateText),
                  const DottedlineWidget(),
                  _infoRow('No Whatsapps Pelanggan', phone),
                  const DottedlineWidget(),
                  _infoRow('Jenis Perbaikan', repairType),
                  const DottedlineWidget(),
                  _infoRow(
                    'Kelengkapan',
                    (_current['completeness'] ?? '-')?.toString() ?? '-',
                  ),
                  const DottedlineWidget(),

                  // jika selesai -> tunjukkan rincian & biaya
                  if (_isSelesai) ...[
                    _infoRow('Rincian', detailPart.toString()),
                    const SizedBox(height: 8),
                    _infoRow(
                      'Biaya',
                      cost.toString().isEmpty
                          ? '-'
                          : _fmtRupiah(cost.toString()),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!_isSelesai) const SizedBox(height: 8),

                  // tombol status (tampilan di bawah; bukan wajib)
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // jika sedang save, tampilkan floating progress
      floatingActionButton: _saving ? const CircularProgressIndicator() : null,
    );
  }

  Widget _infoRow(String label, String value) {
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

  InputDecoration _inputDecoration({
    String? label,
    String? hint,
    String? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,

      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: TextStyle(
        color: MyColors.secondary,
        fontWeight: FontWeight.w600,
      ),

      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColors.secondary, width: 1.5),
      ),
    );
  }
}
