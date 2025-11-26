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

import 'package:flutter/material.dart';

class CapturePage extends StatelessWidget {
  const CapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capture Page")),
      body: const Center(child: Text("This is the Capture Page")),
    );
  }
}
