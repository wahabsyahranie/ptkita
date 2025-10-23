import 'package:flutter/material.dart';
import 'package:flutter_kita/Login.dart';
import 'package:flutter_kita/home.dart';
import 'package:flutter_kita/register.dart';
import 'package:flutter_kita/styles/colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Bagian atas: background merah
            Expanded(
              flex: 6,
              child: Container(
                color: MyColors.primary,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "PT.KITA",
                          style: TextStyle(
                            color: MyColors.background,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ClipRRect(
                          child: Image.asset(
                            "assets/images/welcome_pict.png",
                            width: double.infinity,
                            // fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bagian bawah: background putih
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi.",
                      style: TextStyle(
                        color: MyColors.secondary,
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Manajemen Stok Barang dengan cepat dan efisien.",
                      style: TextStyle(
                        color: MyColors.background,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tombol daftar
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Register(),
                              ),
                            );
                          },
                          child: Container(
                            width: 210,
                            height: 45,
                            decoration: BoxDecoration(
                              color: MyColors.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Daftar",
                              style: TextStyle(
                                fontSize: 14,
                                color: MyColors.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol masuk
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          },
                          child: Container(
                            width: 210,
                            height: 45,
                            decoration: BoxDecoration(
                              color: MyColors.tertiary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 14,
                                color: MyColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
