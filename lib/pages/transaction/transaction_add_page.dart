import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionAddPage extends StatefulWidget {
  const TransactionAddPage({super.key});

  @override
  State<TransactionAddPage> createState() => _TransactionAddPageState();
}

class _TransactionAddPageState extends State<TransactionAddPage> {
  // =========================
  // FORM CONTROLLERS
  // =========================
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  // =========================
  // FOCUS NODES (UX)
  // =========================
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  // =========================
  // FIRESTORE
  // =========================
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // ITEMS FROM DB
  // =========================
  List<Map<String, dynamic>> _items = [];
  String? _selectedItemId;
  Map<String, dynamic>? _selectedItem;

  // =========================
  // ITEM FORM STATE
  // =========================
  int _qty = 1;
  bool _hasWarranty = true;
  int _warrantyYear = 1;
  String _warrantyType = 'Jasa';

  // =========================
  // TRANSACTION DATE
  // =========================
  DateTime? _transactionDate;

  DateTime _addYears(DateTime date, int years) {
    return DateTime(date.year + years, date.month, date.day);
  }

  // =========================
  // CART
  // =========================
  final List<Map<String, dynamic>> _cartItems = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final snap = await _db.collection('items').get();

    setState(() {
      _items = snap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();
    });
  }

  // =========================
  // TOTAL (AUTO)
  // =========================
  int get _total {
    return _cartItems.fold<int>(0, (sum, item) {
      final int price = item['price'] as int;
      final int qty = item['qty'] as int;
      return sum + (price * qty);
    });
  }

  // =========================
  // ADD ITEM TO CART
  // =========================
  void _addToCart() {
    if (_selectedItem == null) return;
    if (_transactionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal transaksi terlebih dahulu'),
        ),
      );
      return;
    }

    final price = _selectedItem!['price'] as int;

    setState(() {
      _cartItems.add({
        'itemId': _selectedItem!['id'],
        'name': _selectedItem!['name'],
        'price': price,
        'qty': _qty,
        'subtotal': _qty * price,

        // ===== GARANSI (DIRATAKAN) =====
        'hasWarranty': _hasWarranty,
        'warrantyYear': _hasWarranty ? _warrantyYear : 0,
        'warrantyType': _hasWarranty ? _warrantyType : null,
        'serialNumber': '', // nanti bisa diisi kalau mau
      });

      _selectedItem = null;
      _selectedItemId = null;
      _qty = 1;
      _hasWarranty = true;
      _warrantyYear = 1;
      _warrantyType = 'Jasa';
    });
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> _submit() async {
    // =========================
    // VALIDASI (STOP DI SINI)
    // =========================
    if (_nameCtrl.text.trim().isEmpty) {
      _showAlert('Nama pelanggan wajib diisi');
      _nameFocus.requestFocus();
      return;
    }

    if (_phoneCtrl.text.trim().isEmpty) {
      _showAlert('No. HP wajib diisi');
      _phoneFocus.requestFocus();
      return;
    }

    if (_cartItems.isEmpty) {
      _showAlert('Tambahkan item ke transaksi');
      return;
    }

    // =========================
    // HITUNG TOTAL
    // =========================
    final totalQty = _cartItems.fold<int>(0, (s, e) => s + (e['qty'] as int));

    final subtotal = _cartItems.fold<int>(
      0,
      (s, e) => s + (e['subtotal'] as int),
    );

    // =========================
    // CEK STOK SEBELUM SIMPAN
    // =========================
    for (final item in _cartItems) {
      final doc = await FirebaseFirestore.instance
          .collection('items')
          .doc(item['itemId'])
          .get();

      if (!doc.exists) {
        _showAlert('Item ${item['name']} tidak ditemukan');
        return;
      }

      final currentStock = (doc.data()?['stock'] ?? 0) as int;
      final qty = item['qty'] as int;

      if (currentStock < qty) {
        _showAlert(
          'Stok tidak cukup untuk ${item['name']}. '
          'Sisa stok: $currentStock',
        );
        return;
      }
    }

    final txCode = await _generateTxCode();

    // =========================
    // SIMPAN KE FIRESTORE (1x)
    // =========================
    final txRef = FirebaseFirestore.instance.collection('transaction').doc();
    final transactionId = txRef.id;

    await txRef.set({
      'customer': {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      },
      'date': Timestamp.fromDate(_transactionDate ?? DateTime.now()),
      'items': _cartItems,
      'summary': {'subtotal': subtotal, 'totalQty': totalQty, 'txCode': txCode},
      'status': 'Sudah Dibayar',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // =========================
    // 🔥 AUTO CREATE WARRANTY (DI SINI)
    // =========================
    final transactionDate = _transactionDate ?? DateTime.now();

    await _createWarrantiesFromTransaction(
      transactionId: transactionId,
      buyerName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text,
      items: _cartItems,
      transactionDate: transactionDate,
    );

    // =========================
    // OPTIONAL: KURANGI STOK
    // =========================
    for (final item in _cartItems) {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(item['itemId'])
          .update({'stock': FieldValue.increment(-(item['qty'] as int))});
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil disimpan')),
    );

    Navigator.pop(context, {'ok': true});
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: MyColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Nama Pelanggan'),
                    TextField(
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      decoration: _inputDecoration(hint: 'Nama pelanggan'),
                    ),
                    const SizedBox(height: 14),

                    _label('No. HP'),
                    TextField(
                      controller: _phoneCtrl,
                      focusNode: _phoneFocus,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(hint: '08xxxxxxxxxx'),
                    ),
                    const SizedBox(height: 14),

                    _label('Tanggal Transaksi'),
                    TextField(
                      controller: _dateCtrl,
                      readOnly: true,
                      decoration: _inputDecoration(
                        hint: 'Pilih tanggal',
                        suffixIcon: Icons.calendar_today_rounded,
                      ),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 14),

                    _label('Pilih Item / Barang'),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedItemId,
                      items: _items.map<DropdownMenuItem<String>>((e) {
                        return DropdownMenuItem<String>(
                          value: e['id'] as String,
                          child: Text(e['name']),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedItemId = v;
                          _selectedItem = _items.firstWhere(
                            (e) => e['id'] == v,
                          );
                        });
                      },
                      decoration: _inputDecoration(hint: 'Pilih item'),
                    ),

                    if (_selectedItem != null) ...[
                      const SizedBox(height: 16),
                      _itemDetailCard(),
                    ],

                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _selectedItem == null ? null : _addToCart,
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: MyColors.secondary,
                      ),
                      label: Text(
                        'Tambah Item ke Transaksi',
                        style: TextStyle(
                          color: MyColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (_cartItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _label('Item dalam Transaksi'),
                      const SizedBox(height: 8),
                      ..._cartItems.asMap().entries.map(
                        (e) => _cartItemCard(e.key, e.value),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // TOTAL + SUBMIT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Rp ${_fmt(_total)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: _cartItems.isEmpty ? null : _submit,
                      child: const Text(
                        'Simpan',
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
          ],
        ),
      ),
    );
  }

  // =========================
  // ITEM DETAIL
  // =========================
  Widget _itemDetailCard() {
    final price = _selectedItem!['price'] as int;
    final stock = _selectedItem!['stock'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.secondary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedItem!['name'],
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Rp ${_fmt(price)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text('Stok: $stock', style: const TextStyle(fontSize: 12)),
                ],
              ),
              // TOMBOL HAPUS / BATAL
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedItem = null;
                    _selectedItemId = null;
                    _qty = 1;
                    _hasWarranty = true;
                    _warrantyYear = 1;
                    _warrantyType = 'Jasa';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          _subLabel('Jumlah'),
          Row(
            children: [
              _qtyButton(
                icon: Icons.remove,
                onTap: _qty > 1 ? () => setState(() => _qty--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_qty',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _qtyButton(
                icon: Icons.add,
                onTap: _qty < stock ? () => setState(() => _qty++) : null,
              ),
            ],
          ),
          const SizedBox(height: 14),

          _subLabel('Garansi'),
          Row(
            children: [
              _radioBool(
                label: 'Ada',
                value: true,
                group: _hasWarranty,
                onChanged: (v) => setState(() => _hasWarranty = v),
              ),
              _radioBool(
                label: 'Tidak Ada',
                value: false,
                group: _hasWarranty,
                onChanged: (v) => setState(() => _hasWarranty = v),
              ),
            ],
          ),

          if (_hasWarranty) ...[
            const SizedBox(height: 14),
            _subLabel('Durasi Garansi'),
            Row(
              children: [
                _radioInt(
                  label: '1 Tahun',
                  value: 1,
                  group: _warrantyYear,
                  onChanged: (v) => setState(() => _warrantyYear = v),
                ),
                _radioInt(
                  label: '2 Tahun',
                  value: 2,
                  group: _warrantyYear,
                  onChanged: (v) => setState(() => _warrantyYear = v),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _subLabel('Jenis Garansi'),
            DropdownButtonFormField<String>(
              value: _warrantyType,
              items: const [
                DropdownMenuItem(value: 'Jasa', child: Text('Jasa')),
                DropdownMenuItem(value: 'SparePart', child: Text('SparePart')),
                DropdownMenuItem(
                  value: 'Jasa & SparePart',
                  child: Text('Jasa & SparePart'),
                ),
              ],
              onChanged: (v) => setState(() => _warrantyType = v!),
              decoration: _inputDecoration(
                hint: 'Pilih jenis garansi',
                suffixIcon: Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================
  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
  );

  Widget _subLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );

  Widget _qtyButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MyColors.secondary.withValues(alpha: 0.6)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey : MyColors.secondary,
        ),
      ),
    );
  }

  Widget _radioBool({
    required String label,
    required bool value,
    required bool group,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: group,
          activeColor: MyColors.secondary,
          onChanged: (v) => onChanged(v!),
        ),
        Text(label),
      ],
    );
  }

  Widget _radioInt({
    required String label,
    required int value,
    required int group,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: group,
          activeColor: MyColors.secondary,
          onChanged: (v) => onChanged(v!),
        ),
        Text(label),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      // DEFAULT / IDLE (belum disentuh)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.black, // 🔥 hitam jelas
          width: 1,
        ),
      ),

      // FOCUS (saat disentuh)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: MyColors.secondary, width: 1.5),
      ),

      // OPTIONAL (biar konsisten)
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // =========================
  // generate txCode
  // =========================
  Future<String> _generateTxCode() async {
    final year = DateTime.now().year;
    final counterRef = _db.collection('counters').doc('tx_$year');

    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int current = 0;
      if (snapshot.exists) {
        current = snapshot['value'] as int;
      }

      final next = current + 1;

      transaction.set(counterRef, {'value': next}, SetOptions(merge: true));

      final number = next.toString().padLeft(5, '0');
      return 'TX-$year-$number';
    });
  }

  // =========================
  // alert message
  // =========================
  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Perhatian'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (d != null) {
      setState(() {
        _transactionDate = d;
        _dateCtrl.text =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      });
    }
  }

  Future<void> _createWarrantiesFromTransaction({
    required String transactionId,
    required String buyerName,
    required String phone,
    required List<Map<String, dynamic>> items,
    required DateTime transactionDate,
  }) async {
    final warrantyRef = FirebaseFirestore.instance.collection('warranty');

    for (final item in items) {
      if (item['hasWarranty'] != true) continue;

      final int duration = (item['warrantyYear'] ?? 0) as int;
      if (duration <= 0) continue;

      final int qty = (item['qty'] ?? 1) as int;

      for (int i = 0; i < qty; i++) {
        final startAt = transactionDate;
        final expireAt = DateTime(
          transactionDate.year + duration,
          transactionDate.month,
          transactionDate.day,
        );

        await warrantyRef.add({
          'transactionId': transactionId,
          'itemId': item['itemId'],
          'buyerName': buyerName.trim(),
          'phone': phone.trim(),

          'productName': item['name'],
          'serialNumber': '',
          'warrantyType': item['warrantyType'], // 🔥 TAMBAHKAN INI

          'startAt': Timestamp.fromDate(startAt),
          'expireAt': Timestamp.fromDate(expireAt),
          'createdAt': FieldValue.serverTimestamp(),

          'status': 'Active',
          'claimCount': 0,
        });
      }
    }
  }

  String _fmt(int v) {
    final s = v.toString().split('').reversed.toList();
    final parts = <String>[];
    for (var i = 0; i < s.length; i += 3) {
      parts.add(s.skip(i).take(3).toList().reversed.join());
    }
    return parts.reversed.join('.');
  }

  Widget _cartItemCard(int index, Map<String, dynamic> item) {
    final subtotal = item['price'] * item['qty'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _cartItems.removeAt(index)),
                child: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Qty ${item['qty']} × Rp ${_fmt(item['price'])}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            item['hasWarranty'] == true
                ? 'Garansi ${item['warrantyYear']} Tahun (${item['warrantyType']})'
                : 'Tanpa Garansi',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Subtotal: Rp ${_fmt(subtotal)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
