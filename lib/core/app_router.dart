import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/login_page.dart';
import '../repositories/user/firestore_user_repository.dart';
import '../services/user/user_service.dart';
import '../pages/home/home_page.dart';

class AppRouter extends StatelessWidget {
  AppRouter({super.key});

  final UserService _userService = UserService(FirestoreUserRepository());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _userService.authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomePage(userService: _userService);
        }

        // return WelcomeScreenPage(userService: _userService);

        return LoginPage(userService: _userService);
      },
    );
  }
}
