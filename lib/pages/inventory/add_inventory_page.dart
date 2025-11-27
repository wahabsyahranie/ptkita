// lib/pages/inventory/add_inventory_page.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_kita/styles/colors.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  String? _selectedType; // 'unit' atau 'part'

  // image picker
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _skuCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  bool _isSaving = false;
  double _uploadProgress = 0.0;

  // NOTE: pakai bucket yang kamu lihat di Firebase Console.
  // Ganti jika berbeda.
  static const String _storageBucket = 'gs://ptkita-44a19.firebasestorage.app';

  // PICK IMAGE
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
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
                  title: const Text('Hapus Gambar'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _imageFile = null);
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

  // UPLOAD IMAGE to explicit bucket, return download URL (or null)
  Future<String?> _uploadImageFile(File file) async {
    try {
      // Pastikan kita upload ke bucket yang sama dengan Console
      final storage = FirebaseStorage.instanceFor(
        bucket: _storageBucket,
      ); // explicit

      final fileName =
          'items/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = storage.ref().child(fileName);

      final uploadTask = ref.putFile(file);

      // listen progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snap) {
        final total = snap.totalBytes ?? 1;
        final progress = snap.bytesTransferred / total;
        setState(() => _uploadProgress = progress);
        debugPrint(
          'Upload status: ${snap.state} — ${(progress * 100).toStringAsFixed(0)}%',
        );
      });

      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final url = await snapshot.ref.getDownloadURL();
        debugPrint('Upload succeeded. downloadURL=$url');
        return url;
      } else {
        debugPrint('Upload finished with state=${snapshot.state}');
        return null;
      }
    } catch (e, st) {
      debugPrint('uploadImage error: $e\n$st');
      rethrow;
    } finally {
      // reset progress after short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _uploadProgress = 0.0);
      });
    }
  }

  // SAVE metadata to Firestore
  Future<void> _saveItemToFirestore({
    required String name,
    required String sku,
    required num price,
    required int stock,
    required String? type,
    String? imageUrl,
    String? description,
  }) async {
    final col = FirebaseFirestore.instance.collection('items');
    final doc = {
      'name': name,
      'sku': sku,
      'price': price,
      'stock': stock,
      'type': type ?? 'unit',
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await col.add(doc);
  }

  // MAIN SAVE HANDLER
  Future<void> _onSavePressed() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameCtrl.text.trim();
    final sku = _skuCtrl.text.trim();
    final priceText = _priceCtrl.text.trim();
    final stockText = _stockCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    final priceNum =
        num.tryParse(priceText.replaceAll(',', '').replaceAll('.', '')) ?? 0;
    final stockNum =
        int.tryParse(stockText.replaceAll(',', '').replaceAll('.', '')) ?? 0;

    String? imageUrl;
    try {
      // show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Menyimpan...'),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: _uploadProgress),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (_imageFile != null) {
        debugPrint('Start upload image: ${_imageFile!.path}');
        imageUrl = await _uploadImageFile(_imageFile!);
        debugPrint('Got imageUrl: $imageUrl');
        if (imageUrl == null) {
          // Upload gagal — tutup dialog, tampilkan pesan dan stop
          Navigator.of(context).pop(); // tutup progress dialog
          throw Exception('Upload gambar gagal. Periksa rules / koneksi.');
        }
      } else {
        debugPrint('No image selected; skipping upload.');
      }

      await _saveItemToFirestore(
        name: name,
        sku: sku,
        price: priceNum,
        stock: stockNum,
        type: _selectedType,
        imageUrl: imageUrl,
        description: desc.isEmpty ? null : desc,
      );

      Navigator.of(context).pop(); // tutup progress dialog
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item berhasil disimpan')));
        Navigator.of(context).pop(); // kembali ke layar sebelumnya
      }
    } catch (e, st) {
      debugPrint('Save flow error: $e\n$st');
      try {
        Navigator.of(context).pop(); // pastikan dialog tertutup
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
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
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
                        if (_imageFile != null)
                          Positioned.fill(
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.image, size: 40),
                                SizedBox(height: 8),
                                Text('Tambah gambar (ketuk untuk pilih)'),
                              ],
                            ),
                          ),
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
                  autofocus: true,
                  cursorColor: MyColors.background,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Masukkan nama barang",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Masukkan SKU barang",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Harga barang",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Masukkan jumlah stok",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
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
                const Text("Tipe"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
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
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tipe wajib diisi';
                    }
                    final n = num.tryParse(
                      v.replaceAll(',', '').replaceAll('.', ''),
                    );
                    if (n == null) return 'Masukkan angka yang valid';
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
                  cursorColor: MyColors.secondary,
                  decoration: InputDecoration(
                    hintText: "Jelaskan deskripsi produk",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MyColors.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Deskripsi wajib diisi';
                    }
                    final n = num.tryParse(
                      v.replaceAll(',', '').replaceAll('.', ''),
                    );
                    if (n == null) return 'Masukkan angka yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving ? null : _onSavePressed,
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
                      : const Text(
                          "Simpan",
                          style: TextStyle(fontSize: 14, color: MyColors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
