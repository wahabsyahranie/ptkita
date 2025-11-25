import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class NavigationBottomWidget extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const NavigationBottomWidget({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: MyColors.secondary,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left icon (index 0)
            IconButton(
              onPressed: () => onTap(0),
              icon: Icon(Icons.home, color: MyColors.background),
            ),

            // Spacer to leave center space for FAB
            Row(
              children: [
                // Right-of-center icon (index 2)
                IconButton(
                  onPressed: () => onTap(2),
                  icon: Icon(
                    Icons.home_repair_service,
                    color: MyColors.background,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
