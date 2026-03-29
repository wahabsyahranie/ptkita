import 'package:flutter/material.dart';
import 'package:flutter_kita/models/warranty/warranty_model.dart';
import 'package:flutter_kita/services/warranty/warranty_service.dart';
import 'package:flutter_kita/core/widgets/forms/app_text.dart';
import 'package:flutter_kita/styles/colors.dart';

class WarrantyAddPage extends StatefulWidget {
  const WarrantyAddPage({super.key});

  @override
  State<WarrantyAddPage> createState() => _WarrantyAddPageState();
}

class _WarrantyAddPageState extends State<WarrantyAddPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> brands = [
    "Firman",
    "Dewalt",
    "Black & Decker",
    "DCA",
    "Stanley",
  ];

  String _selectedBrand = "Firman";

  final _buyerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _productController = TextEditingController();
  final _serialController = TextEditingController();

  DateTime? _startDate;
  int _durationMonth = 12;
  int? _maxClaim = 3;

  bool _isLoading = false;

  DateTime calculateExpireDate() {
    return DateTime(
      _startDate!.year,
      _startDate!.month + _durationMonth,
      _startDate!.day,
    );
  }

  Future<void> _saveWarranty() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi tanggal transaksi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final expireDate = calculateExpireDate();
    final status = DateTime.now().isAfter(expireDate) ? "Expired" : "Active";

    final warranty = WarrantyModel(
      buyerName: _buyerController.text.trim(),
      phone: _phoneController.text.trim(),
      productName: _productController.text.trim(),
      serialNumber: _serialController.text.trim(),
      itemId: "",
      transactionId: "",
      warrantyType: "Jasa",
      brand: _selectedBrand,
      maxClaim: _maxClaim,
      startAt: _startDate!,
      expireAt: expireDate,
      claimCount: 0,
      status: status,
      createdAt: DateTime.now(),
    );

    await WarrantyService().addWarranty(warranty);

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Garansi berhasil ditambahkan")),
      );

      Navigator.pop(context, {"ok": true});
    }
  }

  Future<void> _confirmSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon isi tanggal transaksi")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Simpan Garansi?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                "Data garansi yang sudah disimpan tidak dapat dihapus dari aplikasi.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveWarranty();
                      },
                      child: const Text("Simpan"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecorationTheme dropdownDecoration() {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: MyColors.secondary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        title: const Text("Tambah Garansi"),
        backgroundColor: MyColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 6),

              AppTextFormField(
                controller: _buyerController,
                label: "Nama Pelanggan",
                validator: (value) => value == null || value.isEmpty
                    ? "Nama pelanggan wajib diisi"
                    : null,
              ),

              const SizedBox(height: 16),

              AppTextFormField(
                controller: _phoneController,
                label: "No. HP",
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? "Nomor HP wajib diisi"
                    : null,
              ),

              const SizedBox(height: 16),

              AppTextFormField(
                controller: _productController,
                label: "Nama Barang",
                validator: (value) => value == null || value.isEmpty
                    ? "Nama barang wajib diisi"
                    : null,
              ),

              const SizedBox(height: 16),

              AppTextFormField(
                controller: _serialController,
                label: "Nomor Seri",
                validator: (value) => value == null || value.isEmpty
                    ? "Nomor seri wajib diisi"
                    : null,
              ),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _startDate == null
                      ? "Pilih Tanggal Transaksi"
                      : "Tanggal Transaksi: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 12),

              /// BRAND
              DropdownMenu<String>(
                label: const Text("Brand"),
                initialSelection: _selectedBrand,
                inputDecorationTheme: dropdownDecoration(),
                dropdownMenuEntries: brands
                    .map(
                      (brand) => DropdownMenuEntry(value: brand, label: brand),
                    )
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedBrand = value!;
                  });
                },
              ),

              const SizedBox(height: 12),

              /// DURASI GARANSI
              DropdownMenu<int>(
                label: const Text("Durasi Garansi"),
                initialSelection: _durationMonth,
                inputDecorationTheme: dropdownDecoration(),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 12, label: "1 Tahun"),
                  DropdownMenuEntry(value: 24, label: "2 Tahun"),
                  DropdownMenuEntry(value: 36, label: "3 Tahun"),
                ],
                onSelected: (value) {
                  setState(() {
                    _durationMonth = value!;
                  });
                },
              ),

              const SizedBox(height: 12),

              /// BATAS KLAIM
              DropdownMenu<int?>(
                label: const Text("Batas Klaim"),
                initialSelection: _maxClaim,
                inputDecorationTheme: dropdownDecoration(),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: null, label: "Tidak terbatas"),
                  DropdownMenuEntry(value: 1, label: "1 Kali"),
                  DropdownMenuEntry(value: 2, label: "2 Kali"),
                  DropdownMenuEntry(value: 3, label: "3 Kali"),
                  DropdownMenuEntry(value: 5, label: "5 Kali"),
                ],
                onSelected: (value) {
                  setState(() {
                    _maxClaim = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Garansi",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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
