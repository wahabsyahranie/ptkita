import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class SkipMaintenanceSheet extends StatefulWidget {
  final Maintenance maintenance;
  final MaintenanceService service;

  const SkipMaintenanceSheet({
    super.key,
    required this.maintenance,
    required this.service,
  });

  @override
  State<SkipMaintenanceSheet> createState() => _SkipMaintenanceSheetState();
}

class _SkipMaintenanceSheetState extends State<SkipMaintenanceSheet> {
  final TextEditingController _controller = TextEditingController();

  bool _isSaving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final remaining = widget.maintenance.remainingQuantity;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Skip Perawatan",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // 🔥 INFO SISA
            Text("Sisa saat ini: $remaining unit"),
            const SizedBox(height: 8),
            Text(
              "$remaining item akan dilewati",
              style: const TextStyle(color: MyColors.warning),
            ),

            const SizedBox(height: 16),

            // 🔥 INPUT REASON
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Alasan skip",
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: MyColors.error)),
            ],

            const SizedBox(height: 16),

            // 🔥 BUTTON SKIP
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.secondary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MyColors.white,
                        ),
                      )
                    : const Text(
                        "Skip",
                        style: TextStyle(color: MyColors.white),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final reason = _controller.text.trim();

    if (reason.isEmpty) {
      setState(() => _error = "Alasan wajib diisi");
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      final isCycleFinished = await widget.service.skipMaintenance(
        maintenance: widget.maintenance,
        reason: reason,
      );

      if (!mounted) return;

      Navigator.pop(context, isCycleFinished);
    } catch (e) {
      if (e is MaintenanceException) {
        setState(() => _error = e.message);
      } else {
        setState(() => _error = "Terjadi kesalahan");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
