import 'package:flutter/material.dart';

// ⬇ ⬅ Widget ini harus ada di luar class apa pun
class PrimaryOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFD8A25E);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: primary, width: 2),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
