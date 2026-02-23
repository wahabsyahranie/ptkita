import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'analysis_success_page.dart';
import 'analysis_fail_page.dart';
import 'widget/retake_button_widget.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/services/detection_service.dart';
import 'package:flutter_kita/services/firestore_service.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';

class PreviewCapturePage extends StatefulWidget {
  final XFile imageFile;

  const PreviewCapturePage({
    super.key,
    required this.imageFile,
  });

  @override
  State<PreviewCapturePage> createState() =>
      _PreviewCapturePageState();
}

class _PreviewCapturePageState
    extends State<PreviewCapturePage> {
  bool isLoading = false;

  // ===============================
  // ANALYZE IMAGE
  // ===============================
  Future<void> analyzeImage() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final file = File(widget.imageFile.path);

      // 1️⃣ Kirim ke Flask
      final result =
          await DetectionService.detect(file);

      if (!mounted) return;

      print("DECODE RESULT: $result");

      final List predictions =
          result['predictions'] ?? [];

      // 2️⃣ Jika tidak ada prediksi
      if (predictions.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AnalysisFailPage(
                    imageFile: widget.imageFile),
          ),
        );
        return;
      }

      // 3️⃣ Ambil detection pertama
      final first = predictions.first;

      final String label = first['class'];
      final double confidence =
          (first['confidence'] as num)
              .toDouble();

      final Map<String, dynamic> box = {
        'x1': first['x1'],
        'y1': first['y1'],
        'x2': first['x2'],
        'y2': first['y2'],
      };

      print("Label YOLO: $label");

      // 4️⃣ Query Firestore
      final Item? item =
          await FirestoreService
              .getItemByName(label);

      if (!mounted) return;

      if (item == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AnalysisFailPage(
                    imageFile: widget.imageFile),
          ),
        );
        return;
      }

      // 5️⃣ Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AnalysisSuccessPage(
            imageFile: widget.imageFile,
            label: label,
            confidence: confidence,
            box: box,
            item: item,
          ),
        ),
      );
    } catch (e) {
      print("ERROR ANALYZE: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Gagal menghubungi server"),
        ),
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
        child: Column(
          children: [
            const SizedBox(height: 16),

            // BACK BUTTON
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: Container(
                      padding:
                          const EdgeInsets.all(12),
                      decoration:
                          const BoxDecoration(
                        color:
                            MyColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color:
                            MyColors.white,
                      ),
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
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(22),
                    border: Border.all(
                      color:
                          MyColors.secondary,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(20),
                    child: Image.file(
                      File(widget
                          .imageFile.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // RETAKE BUTTON
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 30),
              child: PrimaryOutlineButton(
                text: "Ambil Ulang",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CapturePage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ANALYZE BUTTON
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 30),
              child: GestureDetector(
                onTap:
                    isLoading
                        ? null
                        : analyzeImage,
                child: Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 16,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        MyColors.secondary,
                    borderRadius:
                        BorderRadius
                            .circular(28),
                  ),
                  child: Center(
                    child:
                        isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors
                                          .white,
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Text(
                                "Analisis",
                                style:
                                    TextStyle(
                                  color:
                                      MyColors
                                          .white,
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
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