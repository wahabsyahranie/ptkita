import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';

class AnalysisSuccessPage extends StatefulWidget {
  final XFile imageFile;
  final String label;
  final double confidence;
  final Map<String, dynamic> box;
  final Item item;

  const AnalysisSuccessPage({
    super.key,
    required this.imageFile,
    required this.label,
    required this.confidence,
    required this.box,
    required this.item,
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
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              /// =========================
              /// IMAGE + BOUNDING BOX
              /// =========================
              _buildImageSection(),

              const SizedBox(height: 32),

              /// =========================
              /// DATA CARD
              /// =========================
              _buildInfoCard(),

              const SizedBox(height: 32),

              /// =========================
              /// BUTTONS
              /// =========================
              _buildButtons(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// =============================================
  /// IMAGE SECTION
  /// =============================================
  Widget _buildImageSection() {
    return SizedBox(
      width: double.infinity,
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _imageInfo == null
            ? const Center(
                child: CircularProgressIndicator(color: MyColors.secondary),
              )
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

                      /// Bounding Box (Fix All Device)
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
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// =============================================
  /// INFO CARD
  /// =============================================
  Widget _buildInfoCard() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MyColors.secondary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabelField(label: "Nama Barang", value: widget.item.name ?? '-'),

              const SizedBox(height: 16),

              _LabelField(label: "SKU", value: widget.item.sku ?? '-'),

              const SizedBox(height: 16),

              _LabelField(
                label: "Stok",
                value: (widget.item.stock ?? 0).toString(),
              ),

              const SizedBox(height: 20),

              _LabelField(
                label: "Confidence",
                value: "${(widget.confidence * 100).toStringAsFixed(2)} %",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =============================================
  /// BUTTON SECTION
  /// =============================================
  Widget _buildButtons() {
    return Column(
      children: [
        /// DETAIL BUTTON
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsInventoryPage(itemId: widget.item.id!),
                ),
              );
            },
            child: const Text(
              "Detail Barang",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MyColors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// RETAKE BUTTON
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: MyColors.secondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CapturePage()),
              );
            },
            child: const Text(
              "Ambil Ulang",
              style: TextStyle(
                color: MyColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// =============================================
/// LABEL FIELD WIDGET
/// =============================================
class _LabelField extends StatelessWidget {
  final String label;
  final String value;

  const _LabelField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MyColors.secondary.withOpacity(0.4)),
            color: MyColors.tertiary.withOpacity(0.35),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
