import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/form_maintenance_page.dart';
import 'package:flutter_kita/styles/colors.dart';

class AddEditMaintenancePage extends StatelessWidget {
  final Maintenance? maintenance;
  const AddEditMaintenancePage({super.key, this.maintenance});

  @override
  Widget build(BuildContext context) {
    final isEdit = maintenance != null;
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Perawatan' : 'Tambah Perawatan'),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: FormMaintenancePage(
        initialItem: maintenance,
        onSaved: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop(true);
        },
      ),
    );
  }
}
