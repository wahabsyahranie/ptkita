import 'package:flutter/material.dart';
import 'package:flutter_kita/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "PT Kita",
      theme: ThemeData(fontFamily: 'Poppins'),
      home: WelcomeScreen(),
    );
  }
}
