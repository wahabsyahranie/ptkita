import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';

class AnalysisSuccessPage extends StatefulWidget {
  final XFile imageFile;
  final String label;
  final double confidence;
  final Map<String, dynamic> box;
  final Map<String, dynamic> data;

  const AnalysisSuccessPage({
    super.key,
    required this.imageFile,
    required this.label,
    required this.confidence,
    required this.box,
    required this.data,
  });

  @override
  State<AnalysisSuccessPage> createState() => _AnalysisSuccessPageState();
}

class _AnalysisSuccessPageState extends State<AnalysisSuccessPage> {
  ui.Image? _imageInfo;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.imageFile.path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    if (!mounted) return;

    setState(() {
      _imageInfo = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 🔥 STATUS HEADER
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "Barang Ditemukan",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildImageSection(),

              const SizedBox(height: 32),

              _buildInfoCard(data),

              const SizedBox(height: 32),

              _buildButtons(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // IMAGE + BBOX
  // =========================
  Widget _buildImageSection() {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _imageInfo == null
            ? const Center(child: CircularProgressIndicator())
            : FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _imageInfo!.width.toDouble(),
                  height: _imageInfo!.height.toDouble(),
                  child: Stack(
                    children: [
                      Image.file(
                        File(widget.imageFile.path),
                        width: _imageInfo!.width.toDouble(),
                        height: _imageInfo!.height.toDouble(),
                        fit: BoxFit.fill,
                      ),

                      // 🔴 BOUNDING BOX
                      Positioned(
                        left: widget.box['x1'].toDouble(),
                        top: widget.box['y1'].toDouble(),
                        child: Container(
                          width: widget.box['x2'] - widget.box['x1'],
                          height: widget.box['y2'] - widget.box['y1'],
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
                          ),
                        ),
                      ),

                      // 🔥 LABEL BOX
                      Positioned(
                        left: widget.box['x1'].toDouble(),
                        top: widget.box['y1'].toDouble() - 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: Colors.red,
                          child: Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // =========================
  // INFO CARD
  // =========================
  Widget _buildInfoCard(Map<String, dynamic> data) {
  // 🔥 AMAN: ambil part number
  final partNumber = data['partNumber']?.toString();

  // 🔥 AMAN: ambil type unit
  final typeUnit = data['typeUnit']?.toString();

  // 🔥 LOGIC AMAN
  final isPart = partNumber != null && partNumber.isNotEmpty;

  final code = isPart ? partNumber : (typeUnit ?? '-');
  final codeLabel = isPart ? "Part Number" : "Type Unit";

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ NAMA
        _LabelField(
          label: "Nama Barang",
          value: data['name']?.toString() ?? '-',
        ),
        const SizedBox(height: 16),

        // ✅ PART / UNIT (AMAN)
        _LabelField(
          label: codeLabel,
          value: code,
        ),
        const SizedBox(height: 16),

        // ✅ STOCK
        _LabelField(
          label: "Stock",
          value: (data['stock'] ?? 0).toString(),
        ),
        const SizedBox(height: 16),

        // ✅ CONFIDENCE
        _LabelField(
          label: "Akurasi",
          value: "${(widget.confidence * 100).toStringAsFixed(2)} %",
        ),
      ],
    ),
  );
}

  // =========================
  // BUTTONS
  // =========================
  Widget _buildButtons() {
    final itemId = widget.data['id'];

    return Column(
      children: [
        // 🔥 DETAIL BARANG
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            onPressed: () {
              if (itemId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsInventoryPage(itemId: itemId),
                  ),
                );
              }
            },
            child: const Text(
              "Detail Barang",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔙 KEMBALI
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text("Kembali"),
          ),
        ),
      ],
    );
  }
}

// =========================
// LABEL FIELD
// =========================
class _LabelField extends StatelessWidget {
  final String label;
  final String value;

  const _LabelField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MyColors.secondary),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
