import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_kita/models/warranty/warranty_model.dart';
import 'package:flutter_kita/services/warranty/warranty_service.dart';

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
        const SnackBar(content: Text("Please select transaction date")),
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
        const SnackBar(content: Text("Warranty successfully created")),
      );

      Navigator.pop(context, {"ok": true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Warranty")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Buyer Name", _buyerController),
              _buildTextField("Phone Number", _phoneController),
              _buildTextField("Product Name", _productController),
              _buildTextField("Serial Number", _serialController),

              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _startDate == null
                      ? "Select Transaction Date"
                      : "Transaction Date: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}",
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
                decoration: const InputDecoration(
                  labelText: "Brand",
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: "Warranty Duration",
                  border: OutlineInputBorder(),
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
                          "Warranty will expire on "
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

              ElevatedButton(
                onPressed: _isLoading ? null : _saveWarranty,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save Warranty"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
