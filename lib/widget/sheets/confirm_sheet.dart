// usage:
// final confirmed = await showAppModalSheet<bool>(builder: (_) => ConfirmSheet(...));
// if (confirmed == true) { do deletion... }

import 'package:flutter/material.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;

  const ConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Hapus',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
