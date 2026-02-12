import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'analysis_success_page.dart';
import 'analysis_fail_page.dart';
import 'widget/retake_button_widget.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/services/detection_service.dart';

class PreviewCapturePage extends StatefulWidget {
  final XFile imageFile;

  const PreviewCapturePage({
    super.key,
    required this.imageFile,
  });

  @override
  State<PreviewCapturePage> createState() => _PreviewCapturePageState();
}

class _PreviewCapturePageState extends State<PreviewCapturePage> {
  bool isLoading = false;

  // ==========================================================
  // ANALYZE IMAGE (Flutter → Flask)
  // ==========================================================
  Future<void> analyzeImage() async {
    if (isLoading) return; // 🔥 mencegah double tap

    setState(() => isLoading = true);

    try {
      final file = File(widget.imageFile.path);

      final result = await DetectionService.detect(file);

      if (!mounted) return;

      if (result['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisSuccessPage(
              imageFile: widget.imageFile,
              label: result['label'] ?? "",
              confidence: (result['confidence'] as num).toDouble(),
              box: Map<String, dynamic>.from(result['box'] ?? {}),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisFailPage(
              imageFile: widget.imageFile,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menghubungi server"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ======================
            // TOP BAR
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: MyColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: MyColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ======================
            // IMAGE PREVIEW
            // ======================
            Expanded(
              child: Center(
                child: Container(
                  width: 325,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: MyColors.secondary,
                      width: 1,
                    ),
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

            // ======================
            // AMBIL ULANG BUTTON
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: PrimaryOutlineButton(
                text: "Ambil Ulang",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CapturePage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ======================
            // ANALISIS BUTTON
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                onTap: analyzeImage,
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
      ),
    );
  }
}
