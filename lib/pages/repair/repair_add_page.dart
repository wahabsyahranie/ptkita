import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kita/core/widgets/forms/app_text.dart';

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
      _hpCtrl.text = widget.warrantyData!['phone'] ?? '';
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

          _buyerCtrl.text = result['buyerName'] ?? '';
          _itemCtrl.text = result['productName'] ?? '';
          _hpCtrl.text = result['phone'] ?? '';
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

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final userData = userDoc.data() ?? {};
      final String userName = userData['name'] ?? 'Unknown';

      final bool isWarranty = _repairCategory == 'warranty';

      final payload = {
        'repairCategory': _repairCategory,
        'warrantyId': isWarranty ? _selectedWarrantyId : null,
        'buyerName': _buyerCtrl.text.trim(),
        'itemName': _itemCtrl.text.trim(),

        'techName': userName,
        'technicianUid': uid,

        'createdByUid': uid,
        'createdByName': userName,

        'noHp': _hpCtrl.text.trim(),
        'status': _status,
        'completeness': _completenessCtrl.text.trim(),
        'date': Timestamp.fromDate(_selectedDate),

        'cost':
            int.tryParse(_costCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,

        if (_detailCtrl.text.trim().isNotEmpty)
          'detailPart': _detailCtrl.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),
      };

      // ================= WARRANTY CHECK =================
      if (isWarranty && _selectedWarrantyId != null) {
        final warrantyRef = FirebaseFirestore.instance
            .collection('warranty')
            .doc(_selectedWarrantyId);

        final warrantyDoc = await warrantyRef.get();

        if (!warrantyDoc.exists) {
          throw Exception('Garansi tidak ditemukan');
        }

        final warrantyData = warrantyDoc.data() as Map<String, dynamic>;

        // cek expired
        final Timestamp expireAt = warrantyData['expireAt'];
        final bool isExpired = expireAt.toDate().isBefore(DateTime.now());

        if (isExpired) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Garansi sudah expired, tidak bisa klaim'),
            ),
          );

          setState(() => _saving = false);
          return;
        }

        // ================= CLAIM LIMIT CHECK =================
        final int claimCount = warrantyData['claimCount'] ?? 0;
        final int? maxClaim = warrantyData['maxClaim'];

        if (maxClaim != null && claimCount >= maxClaim) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Batas klaim garansi sudah tercapai')),
          );

          setState(() => _saving = false);
          return;
        }

        // snapshot data warranty
        payload['warrantySnapshot'] = {
          'startAt': warrantyData['startAt'],
          'expireAt': warrantyData['expireAt'],
          'warrantyType': warrantyData['warrantyType'],
          'claimCountBefore': claimCount,
          'maxClaim': maxClaim,
        };

        // buat repair
        final docRef = await FirebaseFirestore.instance
            .collection('repair')
            .add(payload);

        // increment claim
        await warrantyRef.update({'claimCount': FieldValue.increment(1)});

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perbaikan berhasil ditambahkan')),
        );

        Navigator.of(context).pop({'ok': true, 'id': docRef.id});
        return;
      }

      // ================= NON WARRANTY =================
      final docRef = await FirebaseFirestore.instance
          .collection('repair')
          .add(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perbaikan berhasil ditambahkan')),
      );

      Navigator.of(context).pop({'ok': true, 'id': docRef.id});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan perbaikan')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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
                        // ignore: deprecated_member_use
                        groupValue: _repairCategory,
                        // ignore: deprecated_member_use
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
                        // ignore: deprecated_member_use
                        groupValue: _repairCategory,
                        // ignore: deprecated_member_use
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

                AppTextFormField(
                  controller: _buyerCtrl,
                  label: 'Nama Pelanggan',
                  readOnly: _repairCategory == 'warranty',
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                AppTextFormField(
                  controller: _itemCtrl,
                  label: 'Nama Barang',
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  readOnly: _repairCategory == 'warranty',
                ),
                const SizedBox(height: 12),

                AppTextFormField(
                  controller: _technicianController,
                  label: 'Teknisi',
                  readOnly: true,
                ),
                const SizedBox(height: 12),

                AppTextFormField(
                  controller: TextEditingController(
                    text:
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  label: 'Tanggal Masuk',
                  readOnly: true,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),

                AppTextFormField(
                  controller: _hpCtrl,
                  label: 'No. Hp',
                  keyboardType: TextInputType.phone,
                  readOnly: _repairCategory == 'warranty',
                ),
                const SizedBox(height: 12),

                AppTextFormField(
                  controller: _completenessCtrl,
                  label: 'Kelengkapan',
                ),
                const SizedBox(height: 12),

                AppTextFormField(
                  controller: _detailCtrl,
                  label: 'Rincian (opsional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                _label('Biaya'),
                TextFormField(
                  controller: _costCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
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

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final number = int.parse(numericString);

    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          children: [
            /// HANDLE
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// TITLE
            const Text(
              'Pilih Garansi Aktif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// SEARCH FIELD
            Container(
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MyColors.secondary),
              ),
              child: TextField(
                controller: _searchCtrl,
                cursorColor: MyColors.secondary,
                decoration: InputDecoration(
                  hintText: 'Cari nama pembeli / produk',
                  hintStyle: TextStyle(
                    color: MyColors.secondary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: MyColors.secondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// LIST
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

                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade200),

                    itemBuilder: (context, index) {
                      final doc = results[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),

                        title: Text(
                          '${data['buyerName']} - ${data['productName']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: const Text(
                          'Garansi Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MyColors.success,
                          ),
                        ),

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
