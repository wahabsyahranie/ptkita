import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

class NavigationBottomWidget extends StatelessWidget {
  const NavigationBottomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
      onTap: null,
      height: 60,
      circleWidth: 50,
      circleColor: MyColors.secondary,
      activeIndex: 1,
      activeIcons: [
        Icon(Icons.home, color: MyColors.background),
        Icon(Icons.qr_code, color: MyColors.white),
        Icon(Icons.home_repair_service, color: MyColors.background),
      ],
      inactiveIcons: [
        Icon(Icons.home, color: MyColors.background),
        Icon(Icons.qr_code, color: MyColors.secondary),
        Icon(Icons.home_repair_service, color: MyColors.background),
      ],
      color: MyColors.secondary,
      cornerRadius: const BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
      ),
      shadowColor: MyColors.tertiary,
      circleShadowColor: MyColors.tertiary,
    );
  }
}
