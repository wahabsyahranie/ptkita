import 'package:flutter/material.dart';

class MenuInventoryPage extends StatelessWidget {
  const MenuInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Barang')),
      body: const Center(child: Text('Ini halaman inventory')),
    );
  }
}
