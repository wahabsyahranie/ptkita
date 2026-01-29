// lib/pages/repair/repair_add_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart'; // sesuaikan path kalau perlu

class RepairAddPage extends StatefulWidget {
  const RepairAddPage({super.key});

  @override
  State<RepairAddPage> createState() => _RepairAddPageState();
}

class _RepairAddPageState extends State<RepairAddPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final TextEditingController _buyerCtrl = TextEditingController();
  final TextEditingController _itemCtrl = TextEditingController();
  final TextEditingController _techCtrl = TextEditingController();
  final TextEditingController _hpCtrl = TextEditingController();
  final TextEditingController _completenessCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();

  // state
  DateTime _selectedDate = DateTime.now();
  String _repairType = 'Garansi - Servis Jasa';
  String _status = 'Belum Selesai';
  bool _saving = false;

  // allowed repair types (sama seperti sebelumnya)
  final List<String> _repairTypes = [
    'Garansi - Servis Jasa',
    'Garansi - Servis SparePart',
    'Perbaikan Berbayar',
  ];

  @override
  void dispose() {
    _buyerCtrl.dispose();
    _itemCtrl.dispose();
    _techCtrl.dispose();
    _hpCtrl.dispose();
    _completenessCtrl.dispose();
    _detailCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _submit() async {
    // simple validation: required fields
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        'buyerName': _buyerCtrl.text.trim(),
        'itemName': _itemCtrl.text.trim(),
        'techName': _techCtrl.text.trim(),
        'noHp': _hpCtrl.text.trim(),
        'repairType': _repairType,
        'status': _status,
        'completeness': _completenessCtrl.text.trim(),
        // store date as Firestore Timestamp
        'date': Timestamp.fromDate(_selectedDate),
        // optional fields (detail & cost) might be empty
        if (_detailCtrl.text.trim().isNotEmpty)
          'detailPart': _detailCtrl.text.trim(),
        if (_costCtrl.text.trim().isNotEmpty) 'cost': _costCtrl.text.trim(),
        // metadata
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('repair')
          .add(payload);

      // show success + return with new doc id if caller mau pake
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perbaikan berhasil ditambahkan')),
        );
        Navigator.of(context).pop({'ok': true, 'id': docRef.id});
      }
    } catch (e) {
      debugPrint('add repair error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan perbaikan')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Perbaikan'),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Buyer
                _label('Nama Pelanggan'),
                TextFormField(
                  controller: _buyerCtrl,
                  decoration: _inputDecoration(hint: 'Nama pelanggan'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                // Item
                _label('Nama Barang'),
                TextFormField(
                  controller: _itemCtrl,
                  decoration: _inputDecoration(hint: 'Contoh: Bor Listrik'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                // Tech
                _label('Teknisi'),
                TextFormField(
                  controller: _techCtrl,
                  decoration: _inputDecoration(hint: 'Nama teknisi'),
                ),
                const SizedBox(height: 12),

                // Date picker
                _label('Tanggal Masuk'),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: _inputDecoration(
                        hint: _fmtDate(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Phone
                _label('No Whatsapps Pelanggan'),
                TextFormField(
                  controller: _hpCtrl,
                  decoration: _inputDecoration(hint: '08...'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                // Repair type dropdown
                _label('Jenis Perbaikan'),
                DropdownButtonFormField<String>(
                  value: _repairType,
                  items: _repairTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _repairType = v ?? _repairType),
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 12),

                // completeness (keterangan kelengkapan)
                _label('Kelengkapan'),
                TextFormField(
                  controller: _completenessCtrl,
                  decoration: _inputDecoration(
                    hint: 'Contoh: 1 Unit, tanpa aksesoris',
                  ),
                ),
                const SizedBox(height: 12),

                // detail (optional)
                _label('Rincian (opsional)'),
                TextFormField(
                  controller: _detailCtrl,
                  decoration: _inputDecoration(
                    hint: 'Contoh: 1. Rantai 2. Selang Bensin',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // cost (optional)
                _label('Biaya (opsional)'),
                TextFormField(
                  controller: _costCtrl,
                  decoration: _inputDecoration(hint: 'Contoh: 150000'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // status radio (santai default Belum Selesai)
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Belum Selesai'),
                        value: 'Belum Selesai',
                        groupValue: _status,
                        onChanged: (v) =>
                            setState(() => _status = v ?? _status),
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Selesai'),
                        value: 'Selesai',
                        groupValue: _status,
                        onChanged: (v) =>
                            setState(() => _status = v ?? _status),
                        dense: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Perbaikan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MyColors.white,
                            ),
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

  // small helpers & styles
  Widget _label(String s) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(s, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColors.secondary, width: 1.5),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}
