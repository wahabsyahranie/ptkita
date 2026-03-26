import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/customer_form.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/item_detail_card.dart';
import 'widgets/item_selector.dart';
import 'widgets/transaction_total_bar.dart';

import '../../models/transaction/cart_item_model.dart';
import '../../services/transaction/transaction_service.dart';

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

  // final FocusNode _nameFocus = FocusNode();
  // final FocusNode _phoneFocus = FocusNode();

  // =========================
  // FIRESTORE
  // =========================
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // SERVICE
  // =========================
  final TransactionService _transactionService = TransactionService();

  // =========================
  // ITEMS
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

  // =========================
  // CART
  // =========================
  final List<CartItemModel> _cartItems = [];

  List<TextEditingController> _serialControllers = [];

  @override
  void initState() {
    super.initState();
    _loadItems();

    _generateSerialControllers();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // =========================
  // LOAD ITEMS
  // =========================
  Future<void> _loadItems() async {
    final snap = await _db.collection('items').get();

    setState(() {
      _items = snap.docs.map((d) {
        return {'id': d.id, ...d.data()};
      }).toList();
    });
  }

  void _generateSerialControllers() {
    _serialControllers = List.generate(_qty, (_) => TextEditingController());
  }

  // =========================
  // TOTAL
  // =========================
  int get _total {
    return _cartItems.fold<int>(0, (acc, item) => acc + item.subtotal);
  }

  // =========================
  // ADD ITEM TO CART
  // =========================
  void _addToCart() {
    if (_selectedItem == null) return;

    final price = _selectedItem!['price'] as int;

    /// ambil serial number dari textfield
    final serialNumbers = _serialControllers.map((e) => e.text.trim()).toList();

    /// validasi serial number jika item = unit
    if (_selectedItem!['category'] == 'unit') {
      for (final sn in serialNumbers) {
        if (sn.isEmpty) {
          _showAlert('Serial number tidak boleh kosong');
          return;
        }
      }
    }

    final cartItem = CartItemModel(
      itemId: _selectedItem!['id'],
      name: _selectedItem!['name'],
      type: _selectedItem!['category'] ?? 'part',
      price: price,
      qty: _qty,
      hasWarranty: _hasWarranty,
      warrantyYear: _hasWarranty ? _warrantyYear : 0,
      warrantyType: _hasWarranty ? _warrantyType : null,
      serialNumbers: serialNumbers,
    );

    setState(() {
      _cartItems.add(cartItem);

      _selectedItem = null;
      _selectedItemId = null;
      _qty = 1;

      _hasWarranty = true;
      _warrantyYear = 1;
      _warrantyType = 'Jasa';

      /// reset serial controller
      _serialControllers.clear();
    });
  }

  // =========================
  // SUBMIT
  // =========================
  bool _isSaving = false;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showAlert('Nama pelanggan wajib diisi');
      return;
    }

    if (_phoneCtrl.text.trim().isEmpty) {
      _showAlert('No HP wajib diisi');
      return;
    }

    if (_cartItems.isEmpty) {
      _showAlert('Tambahkan item ke transaksi');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _transactionService.createTransaction(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        date: _transactionDate ?? DateTime.now(),
        items: _cartItems,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan')),
      );

      Navigator.pop(context, {'ok': true});
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
                    CustomerForm(
                      nameCtrl: _nameCtrl,
                      phoneCtrl: _phoneCtrl,
                      dateCtrl: _dateCtrl,
                      onPickDate: _pickDate,
                    ),

                    const SizedBox(height: 14),

                    ItemSelector(
                      items: _items,
                      selectedItemId: _selectedItemId,
                      onChanged: (v) {
                        setState(() {
                          _selectedItemId = v;

                          _selectedItem = _items.firstWhere(
                            (e) => e['id'] == v,
                          );

                          _generateSerialControllers();
                        });
                      },
                    ),

                    if (_selectedItem != null) ...[
                      const SizedBox(height: 16),

                      ItemDetailCard(
                        item: _selectedItem!,
                        qty: _qty,
                        stock: _selectedItem!['stock'],
                        hasWarranty: _hasWarranty,
                        warrantyYear: _warrantyYear,
                        warrantyType: _warrantyType,
                        serialControllers: _serialControllers,

                        onClose: () {
                          setState(() {
                            _selectedItem = null;
                            _selectedItemId = null;
                            _qty = 1;
                            _hasWarranty = true;
                            _warrantyYear = 1;
                            _warrantyType = 'Jasa';
                          });
                        },

                        onQtyAdd: () {
                          if (_qty < _selectedItem!['stock']) {
                            setState(() {
                              _qty++;
                              _generateSerialControllers();
                            });
                          }
                        },

                        onQtyMinus: _qty > 1
                            ? () {
                                setState(() {
                                  _qty--;
                                  _generateSerialControllers();
                                });
                              }
                            : null,

                        onWarrantyChanged: (v) {
                          setState(() => _hasWarranty = v);
                        },

                        onWarrantyYearChanged: (v) {
                          setState(() => _warrantyYear = v);
                        },

                        onWarrantyTypeChanged: (v) {
                          setState(() => _warrantyType = v);
                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    if (_selectedItem != null) ...[
                      const SizedBox(height: 12),

                      TextButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: MyColors.secondary,
                        ),
                        label: const Text(
                          'Tambah Item ke Transaksi',
                          style: TextStyle(
                            color: MyColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    if (_cartItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _label('Item dalam Transaksi'),
                      const SizedBox(height: 8),

                      ..._cartItems.asMap().entries.map(
                        (e) => CartItemCard(
                          item: e.value,
                          onDelete: () =>
                              setState(() => _cartItems.removeAt(e.key)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            TransactionTotalBar(
              total: _total,
              isDisabled: _cartItems.isEmpty,
              isLoading: _isSaving,
              onSubmit: _submit,
            ),
          ],
        ),
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
}
