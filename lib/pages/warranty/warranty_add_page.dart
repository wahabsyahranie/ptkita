import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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

  // Brand policy (semi-dynamic)
  static const Map<String, int?> brandClaimPolicy = {
    "Firman": null, // unlimited
    "Dewalt": 3,
    "Black & Decker": 3,
    "DCA": 3,
    "Stanley": 3,
  };

  String _selectedBrand = "Firman";

  final _buyerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _productController = TextEditingController();
  final _serialController = TextEditingController();

  DateTime? _startDate;
  int _durationMonth = 12;

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

    final maxClaim = brandClaimPolicy[_selectedBrand];

    final warranty = WarrantyModel(
      buyerName: _buyerController.text.trim(),
      phone: _phoneController.text.trim(),
      productName: _productController.text.trim(),
      serialNumber: _serialController.text.trim(),
      itemId: "",
      transactionId: "",
      warrantyType: "Jasa",
      brand: _selectedBrand,
      maxClaim: maxClaim,
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Batal"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _saveWarranty(); // ← DISINI dipanggil
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

              DropdownButtonFormField<String>(
                initialValue: _selectedBrand,
                decoration: InputDecoration(
                  labelText: "Brand",

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: MyColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                items: brandClaimPolicy.keys
                    .map(
                      (brand) =>
                          DropdownMenuItem(value: brand, child: Text(brand)),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBrand = val!;
                  });
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                initialValue: _durationMonth,
                decoration: InputDecoration(
                  labelText: "Durasi Garansi",

                  filled: true,
                  fillColor: Colors.white,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: MyColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 12, child: Text("1 Tahun")),
                  DropdownMenuItem(value: 24, child: Text("2 Tahun")),
                  DropdownMenuItem(value: 36, child: Text("3 Tahun")),
                ],
                onChanged: (val) {
                  setState(() {
                    _durationMonth = val!;
                  });
                },
              ),

              const SizedBox(height: 12),

              if (_startDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Garansi berlaku hingga: "
                          "${calculateExpireDate().day}/"
                          "${calculateExpireDate().month}/"
                          "${calculateExpireDate().year}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
