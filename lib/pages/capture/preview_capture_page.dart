import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'analysis_success_page.dart';
import 'analysis_fail_page.dart';
import 'widget/retake_button_widget.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/services/detection_service.dart';

class PreviewCapturePage extends StatefulWidget {
  final XFile imageFile;

  const PreviewCapturePage({super.key, required this.imageFile});

  @override
  State<PreviewCapturePage> createState() => _PreviewCapturePageState();
}

class _PreviewCapturePageState extends State<PreviewCapturePage> {
  bool isLoading = false;

  // ===============================
  // HELPER NAVIGATION
  // ===============================
  void goToFail(String status, {String? detectedLabel}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisFailPage(
          imageFile: widget.imageFile,
          status: status,
          detectedLabel: detectedLabel, // 🔥 kirim label kalau ada
        ),
      ),
    );
  }

  // ===============================
  // ANALYZE IMAGE
  // ===============================
  Future<void> analyzeImage() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final file = File(widget.imageFile.path);

      final result = await DetectionService.detect(file);

      if (!mounted) return;

      print("RESULT API: $result");

      final status = result['status'];

      // ===============================
      // ❌ FAILED (tidak terdeteksi)
      // ===============================
      if (status == 'failed') {
        return goToFail('failed');
      }

      // ===============================
      // ⚠️ NOT FOUND (tidak ada di DB)
      // ===============================
      if (status == 'not_found') {
        return goToFail(
          'not_found',
          detectedLabel: result['part_number'], // 🔥 penting
        );
      }

      // ===============================
      // ✅ SUCCESS
      // ===============================
      final data = result['data'];
      final predictions = result['predictions'] ?? [];

      // safety fallback
      if (predictions.isEmpty) {
        return goToFail('failed');
      }

      final first = predictions.first;

      final String label = result['part_number'];
      final double confidence = (first['confidence'] as num).toDouble();

      final Map<String, dynamic> box = {
        'x1': first['x1'],
        'y1': first['y1'],
        'x2': first['x2'],
        'y2': first['y2'],
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisSuccessPage(
            imageFile: widget.imageFile,
            label: label,
            confidence: confidence,
            box: box,
            data: data,
          ),
        ),
      );
    } catch (e) {
      print("ERROR ANALYZE: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menghubungi server")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),

                // BACK BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: MyColors.secondary,
                          size: 38,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // IMAGE PREVIEW
                Expanded(
                  child: Center(
                    child: Container(
                      width: 325,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: MyColors.secondary, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(widget.imageFile.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // RETAKE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: PrimaryOutlineButton(
                    text: "Ambil Ulang",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ANALYZE BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: isLoading ? null : analyzeImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: MyColors.secondary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Analisis",
                                style: TextStyle(
                                  color: MyColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),

            // 🔥 LOADING OVERLAY (lebih profesional)
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}