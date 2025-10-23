import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/widget/navigation_drawer_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.white,
        //APPBAR
        appBar: AppBar(title: const Text('PT.KITA')),
        //DRAWER
        drawer: NavigationDrawerWidget(),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Mohon maaf susah diajak ketemu, jadi sulit ngerjain bareng.\nMasih ada tanggungjawab di organisasi yang perlu diselesaikan\nSegenap Cinta dari Wahab ",
              ),
            ],
          ),
        ),
        //NAVIGASI BAWAH MENGGUNAKAN PUB.dev
        bottomNavigationBar: CircleNavBar(
          onTap: null,
          height: 60,
          circleWidth: 50,
          circleColor: MyColors.secondary,
          activeIndex: 1,
          activeIcons: [
            Icon(Icons.home, color: MyColors.background),
            Icon(Icons.qr_code, color: MyColors.primary),
            Icon(Icons.home_repair_service, color: MyColors.background),
          ],
          inactiveIcons: [
            Icon(Icons.home, color: MyColors.background),
            Icon(Icons.qr_code, color: MyColors.secondary),
            Icon(Icons.home_repair_service, color: MyColors.background),
          ],
          color: MyColors.primary,
          cornerRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          shadowColor: MyColors.tertiary,
          circleShadowColor: MyColors.tertiary,
        ),
      ),
    );
  }
}
