import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_kita/pages/home/home_page.dart';
import 'package:flutter_kita/pages/welcome_screen_page.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika sudah login
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Jika belum login → tampilkan Welcome dulu
        return const WelcomeScreenPage();
      },
    );
  }
}
