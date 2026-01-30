// lib/pages/inventory/inventory_form.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:flutter_kita/models/item_model.dart';

class FormInventoryPage extends StatefulWidget {
  /// initialItem == null -> create mode
  /// otherwise -> edit mode (prefill controllers, update doc)
  final Item? initialItem;
  final void Function()? onSaved; // optional callback after save

  const FormInventoryPage({super.key, this.initialItem, this.onSaved});

  @override
  State<FormInventoryPage> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<FormInventoryPage> {
  // image picker
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // form
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
  double _uploadProgress = 0.0;

  // keep existing image url for edit mode (don't overwrite unless user picks new)
  String? _existingImageUrl;

  // NOTE: replace with your bucket if different
  static const String _storageBucket = 'gs://ptkita-44a19.firebasestorage.app';

  @override
  void initState() {
    super.initState();
    final it = widget.initialItem;
    _nameCtrl = TextEditingController(text: it?.name ?? '');
    _skuCtrl = TextEditingController(text: it?.sku ?? '');
    _priceCtrl = TextEditingController(
      text: it?.price != null ? it!.price.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: it?.stock != null ? it!.stock.toString() : '',
    );
    _descCtrl = TextEditingController(text: it?.description ?? '');
    _selectedType = it?.type;
    _existingImageUrl = it?.imageUrl;
    _selectedMerk = it?.merk;
    _locationCtrl = TextEditingController(text: it?.locationCode ?? '');
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
    } catch (e, st) {
      debugPrint('pickImage error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
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
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Hapus Gambar (baru)'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _imageFile = null);
                  },
                ),
              if (_existingImageUrl != null && _imageFile == null)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Hapus gambar lama'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _existingImageUrl = null);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Batal'),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImageFile(File file) async {
    try {
      final storage = FirebaseStorage.instanceFor(bucket: _storageBucket);
      final fileName =
          'items/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = storage.ref().child(fileName);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((snap) {
        final total = snap.totalBytes ?? 1;
        final progress = snap.bytesTransferred / total;
        setState(() => _uploadProgress = progress);
      });

      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == TaskState.success) {
        final url = await snapshot.ref.getDownloadURL();
        return url;
      }
      return null;
    } catch (e, st) {
      debugPrint('uploadImage error: $e\n$st');
      rethrow;
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _uploadProgress = 0.0);
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final sku = _skuCtrl.text.trim();
    final priceText = _priceCtrl.text.trim();
    final stockText = _stockCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final location = _locationCtrl.text.trim();

    final priceNum =
        num.tryParse(priceText.replaceAll(',', '').replaceAll('.', '')) ?? 0;
    final stockNum =
        int.tryParse(stockText.replaceAll(',', '').replaceAll('.', '')) ?? 0;

    String? imageUrl = _existingImageUrl; // start with existing if any

    try {
      // show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: MyColors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: MyColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.initialItem == null
                              ? 'Menyimpan...'
                              : 'Memperbarui...',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // if user picked a new file -> upload and replace url
      if (_imageFile != null) {
        final uploaded = await _uploadImageFile(_imageFile!);
        if (uploaded == null) {
          Navigator.of(context).pop();
          throw Exception('Upload gambar gagal');
        }
        imageUrl = uploaded;
      }

      final col = FirebaseFirestore.instance.collection('items');
      final payload = {
        'name': name,
        'sku': sku,
        'price': priceNum,
        'stock': stockNum,
        'type': _selectedType ?? 'unit',
        'imageUrl': imageUrl,
        'description': desc.isEmpty ? null : desc,
        'merk': _selectedMerk ?? 'nomerk',
        'locationCode': location,
      };

      if (widget.initialItem == null) {
        // add
        await col.add({...payload, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        // update; requires initialItem.id present
        final docId = widget.initialItem!.id;
        if (docId == null) {
          throw Exception('Document id tidak tersedia untuk update');
        }
        await col.doc(docId).update({
          ...payload,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // success
      Navigator.of(context).pop(); // close dialog
      if (mounted) {
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
      }
    } catch (e, st) {
      debugPrint('save error: $e\n$st');
      try {
        Navigator.of(context).pop();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // use existing image preview if available and no new _imageFile
    final previewWidget = _imageFile != null
        ? Image.file(_imageFile!, fit: BoxFit.cover)
        : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
              ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
              : const Center(child: Icon(Icons.image, size: 40)));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image upload field (top)
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(child: previewWidget),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black26,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _showImageOptions,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Nama"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                autofocus: widget.initialItem == null,
                cursorColor: MyColors.background,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan nama barang",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("SKU"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _skuCtrl,
                cursorColor: MyColors.background,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan SKU barang",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "SKU wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Harga"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                cursorColor: MyColors.background,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Harga barang",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  final n = num.tryParse(
                    v.replaceAll(',', '').replaceAll('.', ''),
                  );
                  if (n == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Stok"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockCtrl,
                cursorColor: MyColors.background,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan jumlah stok",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }
                  final n = num.tryParse(
                    v.replaceAll(',', '').replaceAll('.', ''),
                  );
                  if (n == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Rak"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                cursorColor: MyColors.background,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Masukkan kode rak",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Rak wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text("Tipe"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: const [
                  DropdownMenuItem(value: "unit", child: Text("Unit")),
                  DropdownMenuItem(value: "part", child: Text("Part")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Pilih tipe barang",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Tipe wajib diisi';
                  }
                  return null;
                },
                iconEnabledColor: MyColors.background,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 15),
              const Text("Merk"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedMerk,
                items: const [
                  DropdownMenuItem(value: "firman", child: Text("Firman")),
                  DropdownMenuItem(
                    value: "black+decker",
                    child: Text("Black+Decker"),
                  ),
                  DropdownMenuItem(value: "stanley", child: Text("Stanley")),
                  DropdownMenuItem(value: "dewalt", child: Text("Dewalt")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMerk = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Pilih merk barang",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Merk wajib diisi';
                  }
                  return null;
                },
                iconEnabledColor: MyColors.background,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 15),
              const Text("Deskripsi"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                minLines: 4,
                maxLines: 8,
                cursorColor: MyColors.background,
                decoration: InputDecoration(
                  hintText: "Jelaskan deskripsi produk",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.secondary, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
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
}
