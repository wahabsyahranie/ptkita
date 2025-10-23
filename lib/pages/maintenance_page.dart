import 'package:flutter/material.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perawatan')),
      // drawer: NavigationDrawerWidget(),
    );
  }
}
