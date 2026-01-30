import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'analysis_success_page.dart';
import 'widget/retake_button_widget.dart';

class PreviewCapturePage extends StatelessWidget {
  final XFile imageFile;

  const PreviewCapturePage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFD8A25E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ======================
            //        TOP BAR
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ======================
            //        FRAME FOTO
            // ======================
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: primary, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(imageFile.path), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ======================
            //      AMBIL ULANG
            // ======================
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

            const SizedBox(height: 14),

            // ======================
            //        ANALISIS
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                onTap: () {
                  // 🔹 LANGSUNG KE SUCCESS PAGE (DUMMY)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalysisSuccessPage(imageFile: imageFile),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      "Analisis",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
