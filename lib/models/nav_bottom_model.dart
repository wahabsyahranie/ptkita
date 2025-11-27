import 'package:flutter/widgets.dart';

class NavBottomModel {
  final Widget page;
  final GlobalKey<NavigatorState> navKey;

  NavBottomModel({required this.page, required this.navKey});
}
