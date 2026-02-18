import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_kita/pages/home_page.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/capture/preview_capture_page.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  CameraController? controller;
  bool isLoading = true;
  bool hasError = false;

  bool isCapturing = false;
  bool isPicking = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  // ======================
  // CAMERA INITIALIZATION
  // ======================
  Future<void> initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // ======================
  // NAVIGATE
  // ======================
  void navigateToPreview(XFile image) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewCapturePage(imageFile: image)),
    );
  }

  // ======================
  // TAKE PHOTO (SAFE)
  // ======================
  Future<void> takePhoto() async {
    if (isCapturing) return;
    if (controller == null || !controller!.value.isInitialized) return;

    isCapturing = true;

    try {
      final XFile image = await controller!.takePicture();
      if (!mounted) return;

      navigateToPreview(image);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    } finally {
      isCapturing = false;
    }
  }

  // ======================
  // OPEN GALLERY (SAFE)
  // ======================
  Future<void> openGallery() async {
    if (isPicking) return;
    isPicking = true;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        navigateToPreview(image);
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka galeri")));
    } finally {
      isPicking = false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAMERA PREVIEW
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

          // TOP BAR
          Positioned(
            top: 50,
            left: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: MyColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: MyColors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Scan Foto",
                  style: TextStyle(
                    color: MyColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(color: MyColors.secondary),
              child: SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // CAMERA BUTTON
                    GestureDetector(
                      onTap: takePhoto,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyColors.white.withValues(alpha: 0.38),
                          border: Border.all(color: MyColors.white, width: 6),
                        ),
                      ),
                    ),

                    // GALLERY BUTTON
                    Positioned(
                      left: 48,
                      child: GestureDetector(
                        onTap: openGallery,
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: MyColors.white.withValues(alpha: 0.30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image, color: MyColors.white),
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
