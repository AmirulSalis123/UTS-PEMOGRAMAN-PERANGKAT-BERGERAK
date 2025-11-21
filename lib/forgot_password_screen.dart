import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController identifierController = TextEditingController();
  String? _errorMessage;
  bool _showError = false;
  bool _hasBeenValidated = false;

  Future<void> sendOtp(BuildContext context) async {
    String identifier = identifierController.text.trim();

    setState(() {
      _hasBeenValidated = true;
      _showError = false;
      _errorMessage = null;
    });

    // Validasi 1: Field tidak boleh kosong
    if (identifier.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Masukkan Email atau Nomor Telepon Anda.';
      });
      return;
    }

    // Validasi format
    bool isValidFormat = true;
    
    if (identifier.contains('@')) {
      // Validasi format email
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(identifier)) {
        isValidFormat = false;
      }
    } else {
      // Validasi format nomor telepon
      if (!RegExp(r'^[0-9]+$').hasMatch(identifier) || identifier.length < 10) {
        isValidFormat = false;
      }
    }

    // Cek apakah identifier terdaftar di SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedEmail = prefs.getString('email');
    final String? savedPhone = prefs.getString('phone');

    bool isRegistered = false;
    
    if (identifier.contains('@')) {
      // Cek email
      isRegistered = (savedEmail == identifier);
    } else {
      // Cek nomor telepon
      isRegistered = (savedPhone == identifier);
    }

    // Validasi 2: Format tidak valid atau tidak terdaftar
    if (!isValidFormat || !isRegistered) {
      setState(() {
        _showError = true;
        _errorMessage = 'Email/Nomor Telepon tidak terdaftar.';
      });
      return;
    }

    // Simpan identifier untuk digunakan di OTP screen
    await prefs.setString('forgotPasswordIdentifier', identifier);

    // Tentukan apakah ini SMS atau Email
    bool isSms = !identifier.contains('@');

    // Navigasi ke halaman verifikasi OTP dengan mengirim email/phone
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: identifier,
          isForPasswordReset: true,
          isSms: isSms,
        ),
      ),
    );
  }

  // METHOD BARU: Validasi real-time
  void _validateField(String value) {
    if (_hasBeenValidated) {
      final identifier = value.trim();
      
      // Validasi 1: Field tidak boleh kosong
      if (identifier.isEmpty) {
        setState(() {
          _showError = true;
          _errorMessage = 'Masukkan Email atau Nomor Telepon Anda.';
        });
        return;
      }

      // Validasi format
      bool isValidFormat = true;
      
      if (identifier.contains('@')) {
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(identifier)) {
          isValidFormat = false;
        }
      } else {
        if (!RegExp(r'^[0-9]+$').hasMatch(identifier) || identifier.length < 10) {
          isValidFormat = false;
        }
      }

      // Validasi 2: Format tidak valid (anggap sebagai tidak terdaftar untuk konsistensi)
      if (!isValidFormat) {
        setState(() {
          _showError = true;
          _errorMessage = 'Email/Nomor Telepon tidak terdaftar.';
        });
        return;
      }

      // Jika semua validasi passed, hapus error
      setState(() {
        _showError = false;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna icon dan border berdasarkan ada/tidak error
    final Color iconColor = _showError ? Colors.red : Colors.grey;
    final Color borderColor = _showError ? Colors.red : Colors.grey;
    final Color focusedBorderColor = _showError ? Colors.red : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Password'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Masukkan Email atau Nomor Telepon Anda yang terdaftar untuk mendapatkan kode verifikasi.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            TextField(
              controller: identifierController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Email / Nomor Telepon',
                labelStyle: TextStyle(
                  color: _showError ? Colors.red : null,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: focusedBorderColor,
                    width: 2.0,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.person_search,
                  color: iconColor,
                ),
                errorText: _showError ? _errorMessage : null,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
              ),
              onChanged: _validateField,
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () => sendOtp(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim Kode Verifikasi', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}