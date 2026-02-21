import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';

class InventoryFormSubmitButton extends StatelessWidget {
  final bool isSaving;
  final String label;
  final VoidCallback onPressed;

  const InventoryFormSubmitButton({
    super.key,
    required this.isSaving,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.secondary,
        minimumSize: const Size.fromHeight(50),
      ),
      child: isSaving
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                color: MyColors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 14, color: MyColors.white),
            ),
    );
  }
}
