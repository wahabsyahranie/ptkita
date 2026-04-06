import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'preview_capture_page.dart';
import 'widget/retake_button_widget.dart';
import 'package:flutter_kita/styles/colors.dart';

class AnalysisFailPage extends StatefulWidget {
  final XFile imageFile;
  final String status;
  final String? detectedLabel; // 🔥 tambahan

  const AnalysisFailPage({
    super.key,
    required this.imageFile,
    required this.status,
    this.detectedLabel,
  });

  @override
  State<AnalysisFailPage> createState() => _AnalysisFailPageState();
}

class _AnalysisFailPageState extends State<AnalysisFailPage> {
  bool isPicking = false;

  Future<void> pickFromGallery() async {
    if (isPicking) return;
    isPicking = true;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewCapturePage(imageFile: image),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka galeri")),
      );
    } finally {
      isPicking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String message;

    // 🔥 warna & icon beda
    Color mainColor =
        widget.status == 'failed' ? Colors.orange : Colors.red;

    IconData iconData =
        widget.status == 'failed'
            ? Icons.warning_amber_rounded
            : Icons.search_off;

    // ===============================
    // LOGIC STATUS
    // ===============================
    if (widget.status == 'failed') {
      title = "Tidak Ada Objek Terdeteksi";
      message =
          "Kami tidak dapat mengidentifikasi objek dalam gambar.\n"
          "Coba gunakan pencahayaan yang lebih baik.";
    } else {
      title = "Barang Tidak Ditemukan";
      message =
          "Barang terdeteksi (${widget.detectedLabel ?? '-'})\n"
          "tetapi tidak tersedia di inventory.";
    }

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 ICON
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: mainColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: mainColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            iconData,
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // TITLE
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: mainColor,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // MESSAGE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 42),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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

            // 🔁 RETAKE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: PrimaryOutlineButton(
                text: "Ambil Ulang",
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 14),

            // 🖼️ GALLERY BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: GestureDetector(
                onTap: pickFromGallery,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: MyColors.secondary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      "Pilih dari galeri",
                      style: TextStyle(
                        color: MyColors.white,
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