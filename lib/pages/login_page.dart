import 'package:flutter/material.dart';
import 'package:flutter_kita/styles/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isPrecached) {
      precacheImage(const AssetImage('assets/images/login_image.jpg'), context);
      _isPrecached = true;
    }
  }

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _phoneError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    setState(() {
      _phoneError = null;
      _passwordError = null;
    });

    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      setState(() => _phoneError = "Nomor HP tidak boleh kosong");
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = "Password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = "$phone@ptkita.com";

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // ✅ HANYA pop jika sukses
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        if (e.code == 'user-not-found') {
          _phoneError = "Akun tidak ditemukan";
        } else if (e.code == 'wrong-password') {
          _passwordError = "Password salah";
        } else {
          _passwordError = "Login gagal";
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // kita kontrol manual
      onPopInvokedWithResult: (didPop, result) {
        // kalau keyboard terbuka
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusManager.instance.primaryFocus?.unfocus();
          return; // jangan pop
        }

        // kalau tidak ada keyboard → pop manual
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_image.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                height: 420,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 45,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor HP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      cursorColor: MyColors.secondary,
                      decoration: InputDecoration(
                        errorText: _phoneError,
                        labelText: 'Masukkan Nomor HP',

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: MyColors.secondary,
                            width: 2,
                          ),
                        ),

                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),

                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword, // 🔥 ini yang bikin ****
                      cursorColor: MyColors.secondary,
                      decoration: InputDecoration(
                        errorText: _passwordError,
                        labelText: 'Masukkan Password',

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: MyColors.secondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: MyColors.secondary,
                            width: 2,
                          ),
                        ),

                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),

                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                    InkWell(
                      onTap: _isLoading ? null : _login,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: MyColors.secondary,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
