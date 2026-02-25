import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'widgets/repair_receipt_view.dart';
import 'package:flutter_kita/services/repair/repair_service.dart';
import 'package:flutter_kita/services/repair/repair_receipt_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_kita/pages/repair/widgets/complete_repair_sheet.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

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

  final GlobalKey _receiptKey = GlobalKey();

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

  Future<void> _showCompleteForm() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return CompleteRepairSheet(
          detailCtrl: _detailCtrl,
          costCtrl: _costCtrl,
          onSubmit: () async {
            Navigator.pop(context);
            await _markSelesai();
          },
        );
      },
    );
  }

  Future<Uint8List?> _captureReceiptBytes() async {
    try {
      RenderRepaintBoundary boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Perbaikan'),
        backgroundColor: MyColors.white,
        foregroundColor: MyColors.black,
        elevation: 0,
      ),
      backgroundColor: MyColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= RECEIPT (VISIBLE UI) =================
            RepairReceiptView(data: _current),

            if (!_isSelesai) ...[
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _showCompleteForm,
                  child: const Text(
                    "Tandai Selesai",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
            ],

            if (_isSelesai) ...[
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Kirim Bukti ke WhatsApp"),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final bytes = await _captureReceiptBytes();
                    if (bytes == null) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Gagal menangkap bukti")),
                      );
                      return;
                    }

                    final file = await RepairReceiptService.saveReceipt(bytes);
                    if (file == null) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Gagal menyimpan bukti")),
                      );
                      return;
                    }

                    final message =
                        "Halo ${_current['buyerName'] ?? ''}, berikut bukti perbaikan barang Anda.\n\nTerima kasih.";

                    await Share.shareXFiles([XFile(file.path)], text: message);
                  },
                ),
              ),
            ],

            // ================= HIDDEN RECEIPT (FOR CAPTURE ONLY) =================
            Offstage(
              offstage: true,
              child: RepaintBoundary(
                key: _receiptKey,
                child: RepairReceiptView(data: _current),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
