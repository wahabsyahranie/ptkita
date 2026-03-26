import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class FinishMaintenanceSheet extends StatefulWidget {
  final Maintenance maintenance;
  final MaintenanceService service;

  const FinishMaintenanceSheet({
    super.key,
    required this.maintenance,
    required this.service,
  });

  @override
  State<FinishMaintenanceSheet> createState() => _FinishMaintenanceSheetState();
}

class _FinishMaintenanceSheetState extends State<FinishMaintenanceSheet> {
  final TextEditingController _controller = TextEditingController(text: '1');

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
              "Selesaikan Maintenance",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text("Sisa saat ini: $remaining unit"),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah diselesaikan",
                border: OutlineInputBorder(),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: MyColors.error)),
            ],

            const SizedBox(height: 16),

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
                        "Selesaikan",
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
    final value = int.tryParse(_controller.text);
    final remaining = widget.maintenance.remainingQuantity;

    if (value == null || value <= 0) {
      setState(() => _error = "Jumlah tidak valid");
      return;
    }

    if (value > remaining) {
      setState(() => _error = "Tidak boleh melebihi sisa");
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      final isCycleFinished = await widget.service.finishMaintenance(
        maintenance: widget.maintenance,
        completedQuantity: value,
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
