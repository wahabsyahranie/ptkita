import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final String name;
  final String urlImage;

  const UserPage({super.key, required this.name, required this.urlImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Image.network(
        urlImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
