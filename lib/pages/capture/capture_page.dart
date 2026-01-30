// lib/pages/capture_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'preview_capture_page.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  CameraController? controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      // minta izin
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
      // optionally print(e);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // ambil foto lalu ke preview
  Future<void> takePhoto() async {
    try {
      if (controller == null || !controller!.value.isInitialized) return;
      final XFile image = await controller!.takePicture();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewCapturePage(imageFile: image)),
      );
    } catch (e) {
      // handle or show snack
    }
  }

  // pilih dari galeri lalu ke preview
  Future<void> openGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewCapturePage(imageFile: image)),
      );
    } catch (e) {
      // handle
    }
  }

  @override
  Widget build(BuildContext context) {
    // warna konsisten sesuai desainmu
    const Color primary = Color(0xFFD8A25E);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // kamera preview / loading / error
          Positioned.fill(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : hasError
                ? const Center(
                    child: Text(
                      'Camera unavailable',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : CameraPreview(controller!),
          ),

          // top bar
          Positioned(
            top: 50,
            left: 20,
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
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Scan Foto page - foto - Abdul",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              // tinggi panel bawah, bisa diubah sesuai kebutuhan
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(color: primary),
              child: SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // tombol kamera di CENTER (selalu tepat tengah layar)
                    GestureDetector(
                      onTap: takePhoto,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.38),
                          border: Border.all(color: Colors.white, width: 6),
                        ),
                      ),
                    ),

                    // tombol galeri sedikit ke kiri dari tengah
                    Positioned(
                      left:
                          48, // ubah angka ini untuk geser galeri lebih ke kiri/kanan
                      child: GestureDetector(
                        onTap: openGallery,
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
