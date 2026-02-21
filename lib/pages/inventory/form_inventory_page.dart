import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_form_fields_section.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_form_image_section.dart';
import 'package:flutter_kita/pages/inventory/widget/inventory_form_submit_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/inventory/item_model.dart';
import 'package:flutter_kita/services/inventory/inventory_service.dart';
import 'package:flutter_kita/repositories/inventory/firestore_inventory_repository.dart';

class FormInventoryPage extends StatefulWidget {
  final Item? initialItem;
  final void Function()? onSaved;

  const FormInventoryPage({super.key, this.initialItem, this.onSaved});

  @override
  State<FormInventoryPage> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<FormInventoryPage> {
  // Image
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl;

  // Service
  late final InventoryService _service;

  // Form
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;

  String? _selectedType;
  String? _selectedMerk;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final it = widget.initialItem;

    _nameCtrl = TextEditingController(text: it?.name ?? '');
    _skuCtrl = TextEditingController(text: it?.sku ?? '');
    _priceCtrl = TextEditingController(text: it?.price?.toString() ?? '');
    _stockCtrl = TextEditingController(text: it?.stock?.toString() ?? '');
    _descCtrl = TextEditingController(text: it?.description ?? '');
    _locationCtrl = TextEditingController(text: it?.locationCode ?? '');

    _selectedType = it?.type;
    _selectedMerk = it?.merk;
    _existingImageUrl = it?.imageUrl;

    _service = InventoryService(FirestoreInventoryRepository());
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

  // ==============================
  // IMAGE
  // ==============================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Hapus Gambar (baru)'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _imageFile = null);
                  },
                ),
              if (_existingImageUrl != null && _imageFile == null)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Hapus gambar lama'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _existingImageUrl = null);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==============================
  // SAVE
  // ==============================

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final sku = _skuCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    final price =
        int.tryParse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;

    final stock =
        int.tryParse(_stockCtrl.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: MyColors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MyColors.secondary,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: Text('Menyimpan...')),
                ],
              ),
            ),
          ),
        ),
      );

      final item = Item(
        id: widget.initialItem?.id,
        name: name,
        sku: sku,
        price: price,
        stock: stock,
        type: _selectedType ?? 'unit',
        imageUrl: _existingImageUrl,
        description: desc.isEmpty ? null : desc,
        merk: _selectedMerk ?? 'nomerk',
        locationCode: location,
      );

      await _service.saveItem(item, imageFile: _imageFile);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialItem == null
                ? 'Item berhasil disimpan'
                : 'Item berhasil diperbarui',
          ),
        ),
      );

      widget.onSaved?.call();
    } catch (e) {
      try {
        if (mounted) Navigator.pop(context);
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ==============================
  // BUILD
  // ==============================

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
              InventoryFormImageSection(
                imageFile: _imageFile,
                existingImageUrl: _existingImageUrl,
                onTap: _showImageOptions,
              ),
              const SizedBox(height: 16),

              InventoryFormFieldsSection(
                nameCtrl: _nameCtrl,
                skuCtrl: _skuCtrl,
                priceCtrl: _priceCtrl,
                stockCtrl: _stockCtrl,
                locationCtrl: _locationCtrl,
                descCtrl: _descCtrl,
                selectedType: _selectedType,
                selectedMerk: _selectedMerk,
                onTypeChanged: (v) => setState(() => _selectedType = v),
                onMerkChanged: (v) => setState(() => _selectedMerk = v),
              ),

              const SizedBox(height: 30),

              InventoryFormSubmitButton(
                isSaving: _isSaving,
                label: widget.initialItem == null ? "Simpan" : "Update",
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
