import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'widget/retake_button_widget.dart';
import 'package:flutter_kita/styles/colors.dart';

class AnalysisSuccessPage extends StatefulWidget {
  final XFile imageFile;
  final String label;
  final double confidence;
  final Map<String, dynamic> box;

  const AnalysisSuccessPage({
    super.key,
    required this.imageFile,
    required this.label,
    required this.confidence,
    required this.box,
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

              SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _imageInfo == null
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final originalWidth = _imageInfo!.width.toDouble();
                            final originalHeight = _imageInfo!.height
                                .toDouble();

                            final scaleX = constraints.maxWidth / originalWidth;
                            final scaleY =
                                constraints.maxHeight / originalHeight;

                            final x1 =
                                (widget.box['x1'] as num).toDouble() * scaleX;
                            final y1 =
                                (widget.box['y1'] as num).toDouble() * scaleY;
                            final x2 =
                                (widget.box['x2'] as num).toDouble() * scaleX;
                            final y2 =
                                (widget.box['y2'] as num).toDouble() * scaleY;

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    File(widget.imageFile.path),
                                    fit: BoxFit.contain, // 🔥 penting
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
                    _LabelField(label: "Hasil Deteksi", value: widget.label),
                    const SizedBox(height: 18),
                    _LabelField(
                      label: "Confidence",
                      value:
                          "${(widget.confidence * 100).toStringAsFixed(2)} %",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: PrimaryOutlineButton(
                  text: "Ambil Ulang",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CapturePage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}

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
            border: Border.all(color: MyColors.secondary.withOpacity(0.5)),
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
