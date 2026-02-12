import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/login_page.dart';
import 'package:flutter_kita/styles/colors.dart';

class WelcomeScreenPage extends StatefulWidget {
  const WelcomeScreenPage({super.key});

  @override
  State<WelcomeScreenPage> createState() => _WelcomeScreenPageState();
}

class _WelcomeScreenPageState extends State<WelcomeScreenPage> {
  bool _isPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isPrecached) {
      precacheImage(
        const AssetImage('assets/images/welcome_image.jpg'),
        context,
      );
      _isPrecached = true;
    }
  }

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
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            SizedBox(
              width: 333,
              child: Text(
                'Lupakan cara konvensional, gunakan sistem digital dan jadikan pengalaman lebih baik.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
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
