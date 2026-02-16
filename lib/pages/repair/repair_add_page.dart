import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RepairAddPage extends StatefulWidget {
  final String? warrantyId;
  final Map<String, dynamic>? warrantyData;

  const RepairAddPage({super.key, this.warrantyId, this.warrantyData});

  @override
  State<RepairAddPage> createState() => _RepairAddPageState();
}

class _RepairAddPageState extends State<RepairAddPage> {
  final _formKey = GlobalKey<FormState>();
  late final bool _isFromWarranty;

  final TextEditingController _buyerCtrl = TextEditingController();
  final TextEditingController _itemCtrl = TextEditingController();
  final TextEditingController _techCtrl = TextEditingController();
  final TextEditingController _hpCtrl = TextEditingController();
  final TextEditingController _completenessCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _technicianController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final _status = 'Belum Selesai';
  bool _saving = false;

  String _repairCategory = 'non_warranty';
  String? _selectedWarrantyId;
  Map<String, dynamic>? _selectedWarrantyData;

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

  @override
  void initState() {
    super.initState();

    _autoFillTechnician();

    _isFromWarranty = widget.warrantyId != null;

    if (_isFromWarranty && widget.warrantyData != null) {
      _repairCategory = 'warranty';
      _selectedWarrantyId = widget.warrantyId;
      _selectedWarrantyData = widget.warrantyData;

      _buyerCtrl.text = widget.warrantyData!['buyerName'] ?? '';
      _itemCtrl.text = widget.warrantyData!['productName'] ?? '';
      _hpCtrl.text = widget.warrantyData!['noHp'] ?? '';
      _costCtrl.text = '0';
    }
  }

  Future<void> _autoFillTechnician() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final name = userDoc.data()?['name'] ?? '';

    setState(() {
      _technicianController.text = name;
    });
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

  Future<void> _openWarrantySelector() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const WarrantySearchSheet(),
    ).then((result) {
      if (result != null) {
        setState(() {
          _selectedWarrantyId = result['id'];
          _selectedWarrantyData = result;
          _buyerCtrl.text = result['buyerName'];
          _itemCtrl.text = result['productName'];
          _costCtrl.text = '0';
        });
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_repairCategory == 'warranty' && _selectedWarrantyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih garansi terlebih dahulu')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      if (uid == null) {
        throw Exception('User tidak ditemukan');
      }

      // Ambil nama user dari collection users
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final userData = userDoc.data() ?? {};
      final String userName = userData['name'] ?? 'Unknown';

      final isWarranty = _repairCategory == 'warranty';

      final payload = {
        'repairCategory': _repairCategory,
        'warrantyId': isWarranty ? _selectedWarrantyId : null,

        'buyerName': _buyerCtrl.text.trim(),
        'itemName': _itemCtrl.text.trim(),

        // 🔥 Auto assign technician
        'techName': userName,
        'technicianUid': uid,

        // 🔥 Metadata pembuat
        'createdByUid': uid,
        'createdByName': userName,

        'noHp': _hpCtrl.text.trim(),
        'status': _status,
        'completeness': _completenessCtrl.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),

        'cost': isWarranty
            ? 0
            : int.tryParse(_costCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
                  0,

        if (_detailCtrl.text.trim().isNotEmpty)
          'detailPart': _detailCtrl.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),
      };

      // ================= WARRANTY SNAPSHOT =================
      if (isWarranty && _selectedWarrantyId != null) {
        final warrantyDoc = await FirebaseFirestore.instance
            .collection('warranty')
            .doc(_selectedWarrantyId)
            .get();

        if (!warrantyDoc.exists) {
          throw Exception('Garansi tidak ditemukan');
        }

        final warrantyData = warrantyDoc.data() as Map<String, dynamic>;

        final Timestamp expireAt = warrantyData['expireAt'];
        final bool isExpired = expireAt.toDate().isBefore(DateTime.now());

        if (isExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Garansi sudah expired, tidak bisa klaim'),
            ),
          );
          setState(() => _saving = false);
          return;
        }

        payload['warrantySnapshot'] = {
          'startAt': warrantyData['startAt'],
          'expireAt': warrantyData['expireAt'],
          'warrantyType': warrantyData['warrantyType'],
          'claimCountBefore': warrantyData['claimCount'],
        };
      }

      final docRef = await FirebaseFirestore.instance
          .collection('repair')
          .add(payload);

      // Update claimCount kalau warranty
      if (isWarranty && _selectedWarrantyId != null) {
        await FirebaseFirestore.instance
            .collection('warranty')
            .doc(_selectedWarrantyId)
            .update({'claimCount': FieldValue.increment(1)});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perbaikan berhasil ditambahkan')),
        );
        Navigator.of(context).pop({'ok': true, 'id': docRef.id});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan perbaikan')),
      );
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
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// CATEGORY
                _label('Kategori Perbaikan'),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Klaim Garansi'),
                        value: 'warranty',
                        groupValue: _repairCategory,
                        onChanged: _isFromWarranty
                            ? null
                            : (v) {
                                setState(() {
                                  _repairCategory = v!;
                                  _costCtrl.text = '0';
                                });
                              },
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Non Garansi'),
                        value: 'non_warranty',
                        groupValue: _repairCategory,
                        onChanged: _isFromWarranty
                            ? null
                            : (v) {
                                setState(() {
                                  _repairCategory = v!;
                                  _selectedWarrantyId = null;
                                  _selectedWarrantyData = null;
                                  _costCtrl.clear();
                                });
                              },
                        dense: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// WARRANTY SELECTOR
                if (_repairCategory == 'warranty' &&
                    _selectedWarrantyId == null) ...[
                  _label('Pilih Garansi Aktif'),
                  GestureDetector(
                    onTap: _openWarrantySelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedWarrantyData == null
                                  ? 'Cari garansi aktif...'
                                  : '${_selectedWarrantyData!['buyerName']} - ${_selectedWarrantyData!['productName']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                _label('Nama Pelanggan'),
                TextFormField(
                  controller: _buyerCtrl,
                  readOnly: widget.warrantyId != null,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 12),

                _label('Nama Barang'),
                TextFormField(
                  controller: _itemCtrl,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 12),

                _label('Teknisi'),
                TextField(
                  controller: _technicianController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                _label('Tanggal Masuk'),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: _inputDecoration(
                        hint:
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _label('No Whatsapp'),
                TextFormField(
                  controller: _hpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 12),

                _label('Kelengkapan'),
                TextFormField(
                  controller: _completenessCtrl,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 12),

                _label('Rincian (opsional)'),
                TextFormField(
                  controller: _detailCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 12),

                _label('Biaya'),
                TextFormField(
                  controller: _costCtrl,
                  enabled: _repairCategory == 'non_warranty',
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hint: _repairCategory == 'warranty'
                        ? 'Gratis (Garansi)'
                        : 'Masukkan biaya',
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
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

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class WarrantySearchSheet extends StatefulWidget {
  const WarrantySearchSheet({super.key});

  @override
  State<WarrantySearchSheet> createState() => _WarrantySearchSheetState();
}

class _WarrantySearchSheetState extends State<WarrantySearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Pilih Garansi Aktif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari nama pembeli / produk',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('warranty')
                    .where('status', isEqualTo: 'Active')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final query = _searchCtrl.text.toLowerCase();

                  final results = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final buyer = (data['buyerName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final product = (data['productName'] ?? '')
                        .toString()
                        .toLowerCase();

                    if (query.isEmpty) return true;

                    return buyer.contains(query) || product.contains(query);
                  }).toList();

                  if (results.isEmpty) {
                    return const Center(child: Text('Tidak ditemukan'));
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final doc = results[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(
                          '${data['buyerName']} - ${data['productName']}',
                        ),
                        subtitle: const Text('Garansi Aktif'),
                        onTap: () {
                          Navigator.pop(context, {'id': doc.id, ...data});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
