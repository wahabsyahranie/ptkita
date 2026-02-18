import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/pages/inventory/details_inventory_page.dart';

class AnalysisSuccessPage extends StatefulWidget {
  final XFile imageFile;
  final String label;
  final double confidence;
  final Map<String, dynamic> box;
  final Item item; // 🔥 cukup kirim object ini saja

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
    const double containerWidth = 325;
    const double containerHeight = 280;

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// ============================
              /// IMAGE + BOUNDING BOX
              /// ============================
              SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _imageInfo == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: MyColors.secondary,
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final originalWidth = _imageInfo!.width.toDouble();
                            final originalHeight = _imageInfo!.height
                                .toDouble();

                            final containerWidth = constraints.maxWidth;
                            final containerHeight = constraints.maxHeight;

                            // Rasio asli gambar
                            final imageRatio = originalWidth / originalHeight;
                            final containerRatio =
                                containerWidth / containerHeight;

                            double displayWidth;
                            double displayHeight;

                            if (imageRatio > containerRatio) {
                              displayWidth = containerWidth;
                              displayHeight = containerWidth / imageRatio;
                            } else {
                              displayHeight = containerHeight;
                              displayWidth = containerHeight * imageRatio;
                            }

                            final offsetX = (containerWidth - displayWidth) / 2;
                            final offsetY =
                                (containerHeight - displayHeight) / 2;

                            final scale = displayWidth / originalWidth;

                            final x1 = widget.box['x1'] * scale + offsetX;
                            final y1 = widget.box['y1'] * scale + offsetY;
                            final x2 = widget.box['x2'] * scale + offsetX;
                            final y2 = widget.box['y2'] * scale + offsetY;

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    File(widget.imageFile.path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  left: x1,
                                  top: y1,
                                  child: Container(
                                    width: x2 - x1,
                                    height: y2 - y1,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 20),

              /// ============================
              /// DATA RINGKAS
              /// ============================
              Container(
                width: 361,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MyColors.secondary, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelField(
                      label: "Nama Barang",
                      value: widget.item.name ?? '-',
                    ),

                    const SizedBox(height: 12),
                    _LabelField(label: "SKU", value: widget.item.sku ?? '-'),

                    const SizedBox(height: 12),
                    _LabelField(
                      label: "Stok",
                      value: (widget.item.stock ?? 0).toString(),
                    ),

                    const SizedBox(height: 18),
                    _LabelField(
                      label: "Confidence",
                      value:
                          "${(widget.confidence * 100).toStringAsFixed(2)} %",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// ============================
              /// DETAIL BUTTON
              /// ============================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsInventoryPage(item: widget.item),
                      ),
                    );
                  },
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: MyColors.secondary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Detail Barang",
                      style: TextStyle(
                        fontSize: 16,
                        color: MyColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// ============================
              /// AMBIL ULANG
              /// ============================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================
/// LABEL FIELD WIDGET
/// ============================
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
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MyColors.secondary.withValues(alpha: 0.5),
            ),
            color: MyColors.tertiary.withValues(alpha: 0.35),
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
