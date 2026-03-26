import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'widgets/repair_receipt_view.dart';
import 'package:flutter_kita/services/repair/repair_service.dart';
import 'package:flutter_kita/pages/repair/widgets/complete_repair_sheet.dart';
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

  // ================= STATUS =================

  bool get _isSelesai =>
      (_current['status'] ?? '').toString().toLowerCase() == 'selesai';

  // ================= MARK SELESAI =================

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

  // ================= BOTTOM SHEET =================

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

  // ================= WHATSAPP =================

  Future<void> _openWhatsApp() async {
    String phone = (_current['noHp'] ?? '').toString().trim();

    if (phone.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor WhatsApp tidak tersedia")),
      );
      return;
    }

    // bersihkan nomor dari spasi, +, -, dll
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // format nomor indonesia
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (phone.startsWith('8')) {
      phone = '62$phone';
    }

    final message =
        "Halo ${_current['buyerName'] ?? ''},\n\n"
        "Perbaikan barang Anda sudah selesai.\n"
        "Silakan lihat bukti perbaikan pada gambar berikut.\n\n"
        "Terima kasih telah menggunakan layanan kami.";

    final Uri url = Uri.parse(
      "https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// RECEIPT UI
              RepairReceiptView(data: _current),

              /// BUTTON TANDAI SELESAI
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

              /// BUTTON WHATSAPP
              if (_isSelesai) ...[
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share_rounded),
                    label: const Text(
                      "Bagikan Bukti ke WhatsApp",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.secondary,
                      foregroundColor: MyColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _openWhatsApp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
