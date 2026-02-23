import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class DottedlineWidget extends StatelessWidget {
  const DottedlineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const dot = "-";
        return Text(
          dot * (width ~/ 8), // tiap 8px satu titik
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: MyColors.black.withValues(alpha: 0.3),
            fontSize: 12,
            letterSpacing: 2,
          ),
        );
      },
    );
  }
}
