import 'package:flutter/material.dart';
import '../../styles/colors.dart';

class ConfirmationSheet extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmationSheet({
    super.key,
    required this.title,
    required this.description,
    required this.onConfirm,
    this.confirmText = "Konfirmasi",
    this.cancelText = "Batal",
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: MyColors.black.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? MyColors.error.withValues(alpha: 0.5)
                          : MyColors.primary,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Text(
                      confirmText,
                      style: const TextStyle(color: MyColors.white),
                    ),
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
