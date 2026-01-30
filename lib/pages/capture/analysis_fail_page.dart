// lib/pages/analysis_fail_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'preview_capture_page.dart';
import 'widget/retake_button_widget.dart'; // ✅ hanya ini widget

const Color primaryColor = Color(0xFFD8A25E);

class AnalysisFailPage extends StatelessWidget {
  final XFile imageFile;

  const AnalysisFailPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ======================
            //   KONTEN UTAMA
            // ======================
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICON X
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      "Tidak Ada Objek Terdeteksi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 42),
                      child: Text(
                        "Kami tidak dapat mengidentifikasi objek\n"
                        "apapun dalam gambar Anda. Coba\n"
                        "posisikan kamera dengan pencahayaan\n"
                        "yang lebih baik",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ======================
            //   AMBIL ULANG (WIDGET)
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
            //   PILIH DARI GALERI (INLINE)
            // ======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreviewCapturePage(imageFile: image),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      "Pilih dari galeri",
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
