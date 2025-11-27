import 'package:flutter/material.dart';

Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent, // kita pake container dengan shape
    barrierColor: Colors.black54,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (ctx) {
      // provide consistent top handle + SafeArea
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, // keyboard
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: builder(ctx),
          ),
        ),
      );
    },
  );
}
