import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/models/maintenance_model.dart';
import 'package:flutter_kita/styles/colors.dart';

class FormMaintenancePage extends StatefulWidget {
  final Maintenance? initialItem;
  final void Function()? onSaved;
  const FormMaintenancePage({super.key, this.initialItem, this.onSaved});

  @override
  State<FormMaintenancePage> createState() => _FormMaintenancePageState();
}

class _FormMaintenancePageState extends State<FormMaintenancePage> {
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
  double _uploadProgress = 0.0;

  static const String _storageBucket = 'gs://ptkita-44a19.firebasestorage.app';

  @override
  void initState() {
    super.initState();
    final it = widget.initialItem;

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

    final now = DateTime.now();

    // ✅ last maintenance (ambil dari data lama kalau edit)
    final DateTime? lastMaintenanceAt =
        widget.initialItem?.lastMaintenanceAt != null
        ? (widget.initialItem!.lastMaintenanceAt as Timestamp).toDate()
        : null;

    // ✅ hitung next maintenance
    final DateTime nextMaintenanceAt = (lastMaintenanceAt ?? now).add(
      Duration(days: intervalDays),
    );

    final payload = {
      'active': true,
      'status': 'pending',
      'priority': _selectedPriority,

      // 🔗 reference ke item
      'itemId': FirebaseFirestore.instance
          .collection('items')
          .doc(_selectedItemId),

      // 📸 snapshot
      'itemName': _selectedItemName,
      'sku': _selectedItemSku,

      // ⏱ interval & jadwal
      'intervalDays': intervalDays,
      'lastMaintenanceAt': lastMaintenanceAt,
      'nextMaintenanceAt': nextMaintenanceAt,

      // 🧩 tasks
      'tasks': tasksPayload,
    };

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: MyColors.secondary),
        ),
      );

      final col = FirebaseFirestore.instance.collection('maintenance');

      if (widget.initialItem == null) {
        await col.add({...payload, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await col.doc(widget.initialItem!.id!).update({
          ...payload,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.of(context).pop();

      if (mounted) {
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
      }
    } catch (e) {
      Navigator.of(context).pop();
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

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 40,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('Tidak ada barang');
                  }

                  final items = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    value: _selectedItemId,
                    isExpanded: true,

                    items: items.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(
                          data['name'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      final selectedDoc = items.firstWhere(
                        (d) => d.id == value,
                      );
                      final data = selectedDoc.data() as Map<String, dynamic>;

                      setState(() {
                        _selectedItemId = value;
                        _selectedItemName = data['name'];
                        _selectedItemSku = data['sku']; // 🔥 AMBIL SKU
                      });
                    },

                    dropdownColor: MyColors.secondary,
                    icon: const Icon(Icons.arrow_drop_down), // ⬅️ override icon
                    iconSize: 20,

                    decoration: InputDecoration(
                      hintText: "Pilih Barang",
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),

                      // 🔥 INI KUNCI OVERFLOW
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyColors.secondary,
                          width: 2,
                        ),
                      ),
                      border: const OutlineInputBorder(),
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
                decoration: InputDecoration(
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
                decoration: InputDecoration(
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
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 15),
              const Text("Jenis Perawatan"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: MyColors.background),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ..._tasks.map(_buildTaskItem).toList(),

                    TextButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add, color: MyColors.secondary),
                      label: const Text(
                        "Tambah Jenis Perawatan Lain",
                        style: TextStyle(color: MyColors.secondary),
                      ),
                    ),
                  ],
                ),
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
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.initialItem == null ? "Simpan" : "Update",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(TaskForm task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          TextFormField(
            controller: task.titleCtrl,
            cursorColor: MyColors.background,
            decoration: const InputDecoration(
              hintText: 'Judul',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyColors.secondary, width: 2),
              ),
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Judul wajib diisi' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: task.descCtrl,
            cursorColor: MyColors.background,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Deskripsi',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyColors.secondary, width: 2),
              ),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskForm {
  final String id;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  TaskForm(this.id);
}
