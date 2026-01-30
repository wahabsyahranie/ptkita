// lib/pages/analysis_success_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'capture_page.dart';
import 'widget/retake_button_widget.dart';

const Color primaryColor = Color(0xFFD8A25E);

class AnalysisSuccessPage extends StatelessWidget {
  final XFile imageFile;

  // dummy data (nanti dari ML / API)
  final String namaSparepart = "Mata Gerinda";
  final String kodeBarang = "G-927";
  final String stokBarang = "24";

  const AnalysisSuccessPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ======================
              //        FOTO
              // ======================
              Container(
                width: 325,
                height: 280, // lebih tinggi
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(imageFile.path), fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 20),

              // ======================
              //     CARD DETAIL
              // ======================
              Container(
                width: 361,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelField(label: "Nama sparepart", value: namaSparepart),
                    const SizedBox(height: 18),

                    _LabelField(label: "Kode Barang", value: kodeBarang),
                    const SizedBox(height: 18),

                    // ✅ STOK BARANG (BARU)
                    _LabelField(label: "Stok Barang", value: stokBarang),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ======================
              //     TOMBOL (TETAP)
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Text(
                      "Detail Barang",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

// ==================================================
//     LABEL + VALUE WIDGET
// ==================================================
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
            border: Border.all(color: primaryColor.withOpacity(0.5)),
            color: const Color(0xFFF5F5F5),
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
