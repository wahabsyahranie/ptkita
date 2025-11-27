// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class CapturePage extends StatefulWidget {
//   const CapturePage({super.key});

//   @override
//   State<CapturePage> createState() => _CapturePageState();
// }

// class _CapturePageState extends State<CapturePage> {
//   final ImagePicker picker = ImagePicker();
//   XFile? imageFile;

//   Future<void> pickFromCamera() async {
//     final XFile? file = await picker.pickImage(source: ImageSource.camera);
//     if (file == null) return;
//     if (!mounted) return;

//     // Setelah capture → pindah ke halaman hasil
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => HasilFotoPage(imagePath: file.path)),
//     );
//   }

//   Future<void> pickFromGallery() async {
//     final XFile? file = await picker.pickImage(source: ImageSource.gallery);
//     if (file == null) return;
//     if (!mounted) return;

//     // Masih tetap buka hasil
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => HasilFotoPage(imagePath: file.path)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // =======================
//                 //      TITLE ATAS
//                 // =======================
//                 Padding(
//                   padding: const EdgeInsets.only(top: 5, bottom: 10),
//                   child: Center(
//                     child: Text(
//                       "Scan Foto page - foto - Abdul",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // =======================
//                 //  PREVIEW (ROUNDED 40)
//                 // =======================
//                 Expanded(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(40), // pilihanmu (C)
//                     child: Container(
//                       color: Colors.black,
//                       child: Center(
//                         child: Icon(
//                           Icons.camera_alt_outlined,
//                           color: Colors.white30,
//                           size: 80,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // =======================
//                 // PANEL BAWAH
//                 // =======================
//                 Container(
//                   height: 170,
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFD8A25E),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(35),
//                       topRight: Radius.circular(35),
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // ====== TOMBOL GALERI ======
//                           GestureDetector(
//                             onTap: pickFromGallery,
//                             child: Container(
//                               padding: const EdgeInsets.all(13),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.25),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(
//                                 Icons.photo,
//                                 color: Colors.white,
//                                 size: 28,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(width: 55),

//                           // ====== TOMBOL CAPTURE ======
//                           GestureDetector(
//                             onTap: pickFromCamera,
//                             child: Container(
//                               width: 78,
//                               height: 78,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 6,
//                                 ),
//                                 color: Colors.white.withOpacity(0.4),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // =======================
//             //    TOMBOL BACK
//             // =======================
//             Positioned(
//               top: 15,
//               left: 15,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   height: 45,
//                   width: 45,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFD8A25E),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ========================================================
// // HALAMAN HASIL FOTO (SIMPLE SAAT INI SESUAI JAWABAN NO 6)
// // ========================================================
// class HasilFotoPage extends StatelessWidget {
//   final String imagePath;

//   const HasilFotoPage({super.key, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Hasil Foto"),
//         backgroundColor: Color(0xFFD8A25E),
//       ),
//       body: Center(child: Image.file(File(imagePath), fit: BoxFit.contain)),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class CapturePage extends StatelessWidget {
//   const CapturePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Capture Page")),
//       body: const Center(child: Text("This is the Capture Page")),
//     );
//   }
// }

// lib/pages/capture_page.dart
// lib/pages/capture_page.dart;
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

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    // Minta izin kamera
    var status = await Permission.camera.request();
    if (!status.isGranted) return;

    // Ambil daftar kamera
    final cameras = await availableCameras();

    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // Setup controller
    controller = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // 📸 AMBIL FOTO
  Future<void> takePhoto() async {
    if (!controller!.value.isInitialized) return;

    final XFile image = await controller!.takePicture();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewCapturePage(imageFile: image)),
    );
  }

  // 🖼 PILIH DARI GALERI
  Future<void> openGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewCapturePage(imageFile: image)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // Kamera atau loading
          Positioned.fill(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
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
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD8A25E),
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

          // BOTTOM BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
              decoration: const BoxDecoration(color: Color(0xFFD8A25E)),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🖼 TOMBOL GALERI
                  GestureDetector(
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

                  // 📸 TOMBOL FOTO
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

                  // Spacer agar center
                  const SizedBox(width: 55),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
