import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance/maintenance_model.dart';
import 'package:flutter_kita/repositories/maintenance/firestore_maintenance_repository.dart';
import 'package:flutter_kita/services/maintenance/maintenance_service.dart';
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
  String? _selectedItemSku;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final it = widget.initialItem;
    _service = MaintenanceService(FirestoreMaintenanceRepository());

    _nameCtrl = TextEditingController(text: it?.itemName ?? '');
    _intervalCtrl = TextEditingController(
      text: it?.intervalDays.toString() ?? '',
    );

    _selectedItemId = it?.itemId;
    _selectedItemName = it?.itemName;
    _selectedPriority = it?.priority;
    _selectedItemSku = it?.sku;

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

    if (_selectedItemId == null || _selectedItemSku == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Barang wajib dipilih')));
      return;
    }

    setState(() => _isSaving = true);

    final intervalDays = int.parse(_intervalCtrl.text.trim());

    final tasksPayload = _tasks.map((t) {
      return {
        'id': t.id,
        'title': t.titleCtrl.text.trim(),
        'description': t.descCtrl.text.trim(),
      };
    }).toList();

    final payload = _service.buildPayload(
      itemId: _selectedItemId!,
      itemName: _selectedItemName!,
      sku: _selectedItemSku,
      intervalDays: intervalDays,
      priority: _selectedPriority!,
      lastMaintenance: _service.extractLastMaintenance(widget.initialItem),
      tasks: tasksPayload,
    );

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: MyColors.secondary),
        ),
      );

      await _service.saveMaintenance(
        payload: payload,
        id: widget.initialItem?.id,
      );

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Barang'),
              const SizedBox(height: 8),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _service.streamItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Tidak ada barang');
                  }

                  final items = snapshot.data!;

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedItemId,
                    isExpanded: true,
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'] as String,
                        child: Text(
                          item['name'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      final selectedItem = items.firstWhere(
                        (i) => i['id'] == value,
                      );

                      setState(() {
                        _selectedItemId = value;
                        _selectedItemName = selectedItem['name'];
                        _selectedItemSku = selectedItem['sku'];
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Pilih Barang",
                      border: OutlineInputBorder(),
                    ),
                  );
                },
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
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
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
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
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

              MaintenanceTaskFormSection(tasks: _tasks, onAddTask: _addTask),
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
    );
  }
}
