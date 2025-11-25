import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/login_page.dart';
import 'package:flutter_kita/styles/colors.dart';

class WelcomeScreenPage extends StatelessWidget {
  const WelcomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 333,
              child: Text(
                'Monitoring Stok Unit, dimanapun.',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  color: MyColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 333,
              child: Text(
                'Lupakan cara konvensional, gunakan sistem digital dan jadikan pengalaman lebih baik.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
            InkWell(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: MyColors.secondary,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Selanjutnya",
                  style: TextStyle(
                    fontSize: 18,
                    color: MyColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           children: [
//             // Bagian atas: background merah
//             Expanded(
//               flex: 6,
//               child: Container(
//                 color: MyColors.primary,
//                 width: double.infinity,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           "PT.KITA",
//                           style: TextStyle(
//                             color: MyColors.background,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Expanded(
//                         child: ClipRRect(
//                           child: Image.asset(
//                             "assets/images/welcome_pict.png",
//                             width: double.infinity,
//                             // fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Bagian bawah: background putih
//             Expanded(
//               flex: 4,
//               child: Container(
//                 width: double.infinity,
//                 color: Colors.white,
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Hi.",
//                       style: TextStyle(
//                         color: MyColors.secondary,
//                         fontSize: 60,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     Text(
//                       "Manajemen Stok Barang dengan cepat dan efisien.",
//                       style: TextStyle(
//                         color: MyColors.background,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const Spacer(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Tombol daftar
//                         InkWell(
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => RegisterPage(),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             width: 180,
//                             height: 45,
//                             decoration: BoxDecoration(
//                               color: MyColors.primary,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Daftar",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: MyColors.tertiary,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         // Tombol masuk
//                         InkWell(
//                           onTap: () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => HomePage(),
//                               ),
//                             );
//                           },
//                           child: Container(
//                             width: 180,
//                             height: 45,
//                             decoration: BoxDecoration(
//                               color: MyColors.tertiary,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Masuk",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: MyColors.primary,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
