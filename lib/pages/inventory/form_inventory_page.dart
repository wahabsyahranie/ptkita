import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/styles/colors.dart';

class FormInventoryPage extends StatefulWidget {
  final Item? initialItem;
  final VoidCallback? onSaved;

  const FormInventoryPage({super.key, this.initialItem, this.onSaved});

  @override
  State<FormInventoryPage> createState() => _FormInventoryPageState();
}

class _FormInventoryPageState extends State<FormInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final InventoryService _service;

  File? _imageFile;

  late TextEditingController _nameCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;

  String? _selectedType;
  String? _selectedMerk;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _service = InventoryService(FirestoreInventoryRepository());

    final it = widget.initialItem;

    _nameCtrl = TextEditingController(text: it?.name ?? '');
    _skuCtrl = TextEditingController(text: it?.sku ?? '');
    _priceCtrl = TextEditingController(text: it?.price?.toString() ?? '');
    _stockCtrl = TextEditingController(text: it?.stock?.toString() ?? '');
    _descCtrl = TextEditingController(text: it?.description ?? '');
    _locationCtrl = TextEditingController(text: it?.locationCode ?? '');

    _selectedType = it?.type;
    _selectedMerk = it?.merk;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final item = Item(
      id: widget.initialItem?.id,
      name: _nameCtrl.text.trim(),
      sku: _skuCtrl.text.trim(),
      price: int.tryParse(_priceCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      description: _descCtrl.text.trim(),
      locationCode: _locationCtrl.text.trim(),
      type: _selectedType,
      merk: _selectedMerk,
    );

    await _service.saveItem(item, imageFile: _imageFile);

    if (!mounted) return;

    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                color: MyColors.greySoft,
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 40),
              ),
            ),
            const SizedBox(height: 20),

            _buildField(_nameCtrl, "Nama"),
            _buildField(_skuCtrl, "SKU"),
            _buildField(_priceCtrl, "Harga"),
            _buildField(_stockCtrl, "Stok"),
            _buildField(_locationCtrl, "Rak"),
            _buildField(_descCtrl, "Deskripsi"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.secondary,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: MyColors.white)
                  : const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? "$label wajib diisi" : null,
      ),
    );
  }
}
