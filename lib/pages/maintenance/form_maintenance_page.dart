import 'package:flutter/material.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/pages/maintenance/widgets/item_picker_sheet.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/repositories/user/firestore_user_repository.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
import 'package:flutter_kita/services/user/user_service.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/pages/maintenance/widgets/maintenance_task_form_section.dart';

class FormMaintenancePage extends StatefulWidget {
  final Maintenance? initialItem;
  final void Function()? onSaved;
  const FormMaintenancePage({super.key, this.initialItem, this.onSaved});

  @override
  State<FormMaintenancePage> createState() => _FormMaintenancePageState();
}

class _FormMaintenancePageState extends State<FormMaintenancePage> {
  late final MaintenanceService _service;
  //form
  final _formKey = GlobalKey<FormState>();
  final List<TaskForm> _tasks = [];
  late final TextEditingController _nameCtrl;
  late final TextEditingController _intervalCtrl;
  String? _selectedItemId;
  String? _selectedItemName;
  String? _selectedPriority;
  String? _selectedItemtypeUnit;
  String? _selectedPartNumber;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.initialItem;
    final userService = UserService(FirestoreUserRepository());

    _service = MaintenanceService(
      FirestoreMaintenanceRepository(),
      InventoryService(FirestoreInventoryRepository(), userService),
      userService,
    );

    _nameCtrl = TextEditingController(text: it?.itemName ?? '');
    _intervalCtrl = TextEditingController(
      text: it?.intervalDays.toString() ?? '',
    );

    _selectedItemId = it?.itemId;
    _selectedItemName = it?.itemName;
    _selectedPriority = it?.priority;
    _selectedItemtypeUnit = it?.typeUnit;
    _selectedItemName = it?.itemName;

    // 🔑 LOAD TASKS SAAT EDIT
    if (it != null && it.tasks.isNotEmpty) {
      for (final task in it.tasks) {
        final tf = TaskForm(task.id);
        tf.titleCtrl.text = task.title;
        tf.descCtrl.text = task.description;
        _tasks.add(tf);
      }
    } else {
      // create baru → 1 task default
      _tasks.add(TaskForm('task_1'));
    }
  }

  @override
  //Membersihkan memori
  @override
  void dispose() {
    _nameCtrl.dispose();
    _intervalCtrl.dispose();

    for (final t in _tasks) {
      t.titleCtrl.dispose();
      t.descCtrl.dispose();
    }

    super.dispose();
  }

  void _addTask() {
    setState(() {
      _tasks.add(TaskForm('task_${_tasks.length + 1}'));
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItemId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Barang wajib dipilih')));
      return;
    }

    setState(() => _isSaving = true);

    final intervalDays = int.parse(_intervalCtrl.text.trim());

    final tasks = _tasks.map((t) {
      return MaintenanceTask(
        id: t.id,
        title: t.titleCtrl.text.trim(),
        description: t.descCtrl.text.trim(),
        completed: false,
      );
    }).toList();

    final maintenance = Maintenance(
      id: widget.initialItem?.id ?? '',
      itemId: _selectedItemId!,
      itemName: _selectedItemName!,
      typeUnit: _selectedItemtypeUnit,
      partNumber: _selectedPartNumber,
      intervalDays: intervalDays,
      priority: _selectedPriority!,
      lastMaintenanceAt: widget.initialItem?.lastMaintenanceAt,
      nextMaintenanceAt: widget.initialItem?.nextMaintenanceAt,
      tasks: tasks,
    );

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: MyColors.secondary),
        ),
      );

      await _service.saveMaintenance(maintenance: maintenance);

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialItem == null
                ? 'Maintenance berhasil disimpan'
                : 'Maintenance berhasil diperbarui',
          ),
        ),
      );
      widget.onSaved?.call();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Barang'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final selected = await showModalBottomSheet<Item>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => ItemPickerSheet(service: _service),
                    );

                    if (selected != null) {
                      setState(() {
                        _selectedItemId = selected.id;
                        _selectedItemName = selected.name;
                        _selectedItemtypeUnit = selected.typeUnit;
                        _selectedPartNumber = selected.partNumber;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedItemName ?? 'Pilih Barang',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text("Interval Perawatan (hari)"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _intervalCtrl,
                  cursorColor: MyColors.background,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Masukkan jumlah hari",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Interval wajib diisi';
                    }
                    final n = num.tryParse(
                      v.replaceAll(',', '').replaceAll('.', ''),
                    );
                    if (n == null) return 'Masukkan angka yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                const Text('Prioritas'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  items: const [
                    DropdownMenuItem(value: "rendah", child: Text("Rendah")),
                    DropdownMenuItem(value: "sedang", child: Text("Sedang")),
                    DropdownMenuItem(value: "tinggi", child: Text("Tinggi")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Pilih Prioritas",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Prioritas wajib diisi';
                    }
                    return null;
                  },
                  iconEnabledColor: MyColors.background,
                  dropdownColor: MyColors.white,
                ),
                const SizedBox(height: 15),
                const Text("Jenis Perawatan"),
                const SizedBox(height: 8),

                MaintenanceTaskFormSection(
                  tasks: _tasks,
                  onAddTask: _addTask,
                  onDeleteTask: _removeTask,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.secondary,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: MyColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.initialItem == null ? "Simpan" : "Update",
                          style: const TextStyle(
                            fontSize: 14,
                            color: MyColors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _removeTask(TaskForm task) {
    if (_tasks.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 jenis perawatan')),
      );
      return;
    }

    setState(() {
      task.titleCtrl.dispose();
      task.descCtrl.dispose();
      _tasks.remove(task);
    });
  }
}
