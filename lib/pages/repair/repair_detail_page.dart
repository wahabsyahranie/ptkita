import 'package:flutter/material.dart';
import 'widgets/repair_detail_card.dart';
import 'package:flutter_kita/services/repair/repair_service.dart';
import 'widgets/repair_status_badge.dart';
import 'package:flutter_kita/utils/formatters.dart';
import 'package:flutter_kita/services/repair/repair_receipt_service.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

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
            RepaintBoundary(
              key: _receiptKey,
              child: RepairDetailCard(
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
            ),
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

                    final phone = (_current['noHp'] ?? '').toString().trim();
                    if (phone.isEmpty) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Nomor WhatsApp pelanggan tidak tersedia",
                          ),
                        ),
                      );
                      return;
                    }

                    String formattedPhone = phone.startsWith('0')
                        ? '62${phone.substring(1)}'
                        : phone;

                    final message =
                        "Halo ${_current['buyerName']}, berikut bukti perbaikan barang Anda.\n\nTerima kasih.";

                    final url = Uri.parse(
                      "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}",
                    );

                    if (!mounted) return;

                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );

                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Membuka WhatsApp...")),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "WhatsApp tidak tersedia di perangkat ini",
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
