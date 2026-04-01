import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/capture/preview_capture_page.dart';

class CapturePage extends StatefulWidget {
  const CapturePage({super.key});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> with WidgetsBindingObserver {
  CameraController? _controller;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isCapturing = false;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  // ======================
  // CAMERA INITIALIZATION
  // ======================
  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ======================
  // TAKE PHOTO
  // ======================
  Future<void> _takePhoto() async {
    if (_isCapturing) return;
    if (_controller == null || !_controller!.value.isInitialized) return;

    _isCapturing = true;

    try {
      final XFile image = await _controller!.takePicture();

      // 🔥 kasih delay biar camera release dulu
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewCapturePage(imageFile: image)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil foto")));
    } finally {
      _isCapturing = false;
    }
  }

  // ======================
  // OPEN GALLERY
  // ======================
  Future<void> _openGallery() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewCapturePage(imageFile: image),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka galeri")));
    } finally {
      _isPicking = false;
    }
  }

  // ======================
  // APP LIFECYCLE
  // ======================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    if (!_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _controller?.dispose();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _hasError
                    ? const Center(
                        child: Text(
                          'Camera unavailable',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : (_controller != null && _controller!.value.isInitialized)
                    ? ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.previewSize!.height,
                              height: _controller!.value.previewSize!.width,
                              child: CameraPreview(_controller!),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              // ======================
              // TOP BAR
              // ======================
              Positioned(
                top: 16,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _controller?.dispose();
                        if (!mounted) return;

                        Navigator.popUntil(context, (route) => route.isFirst);
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
                      "Scan Item",
                      style: TextStyle(
                        color: MyColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================
              // BOTTOM BAR
              // ======================
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  color: MyColors.secondary.withOpacity(0.65),
                  child: SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // CAPTURE BUTTON
                        GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MyColors.white.withOpacity(0.38),
                              border: Border.all(
                                color: MyColors.white,
                                width: 6,
                              ),
                            ),
                          ),
                        ),

                        // GALLERY BUTTON
                        Positioned(
                          left: 48,
                          child: GestureDetector(
                            onTap: _openGallery,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: MyColors.white.withOpacity(0.30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: MyColors.white,
                              ),
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
        ),
      ),
    );
  }
}
