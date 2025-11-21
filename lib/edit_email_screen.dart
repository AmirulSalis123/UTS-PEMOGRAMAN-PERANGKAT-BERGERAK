import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_verification_screen.dart';

class EditEmailScreen extends StatefulWidget {
  final String initialValue;
  final VoidCallback? onEmailUpdated;

  const EditEmailScreen({
    Key? key,
    required this.initialValue,
    this.onEmailUpdated,
  }) : super(key: key);

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  late TextEditingController _controller;
  bool _showError = false;
  String _errorMessage = '';
  bool _hasBeenValidated = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialValue != 'email belum diatur') {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      _controller = TextEditingController();
    }

    _controller.addListener(() {
      if (_hasBeenValidated) {
        _validateEmailRealTime(_controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    // Regex untuk validasi format email dasar
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?$'
    );
    
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Daftar TLD yang umum digunakan
    const allowedTlds = [
      'com', 'org', 'net', 'edu', 'gov', 'id', 'co', 'uk', 'jp', 'de', 
      'fr', 'it', 'au', 'ca', 'sg', 'my', 'th', 'vn', 'ph'
    ];

    // Ekstrak bagian domain dan TLD
    final domainParts = email.split('@')[1].split('.');
    final tld = domainParts.last.toLowerCase();
    final domain = domainParts.length > 1 ? domainParts[domainParts.length - 2] : '';

    // VALIDASI KHUSUS: Tolak domain populer dengan TLD tidak standar
    const popularDomains = ['gmail', 'yahoo', 'hotmail', 'outlook', 'icloud'];
    const nonStandardTlds = ['co', 'io', 'ai', 'me', 'tv', 'cc', 'ws'];
    
    if (popularDomains.contains(domain) && nonStandardTlds.contains(tld)) {
      return false; // Tolak gmail.co, yahoo.io, dll
    }

    return allowedTlds.contains(tld);
  }

  void _validateEmailRealTime(String email) {
    if (email.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Email harus diisi';
      });
      return;
    }
    
    if (!_isEmailValid(email)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Format Email tidak valid';
      });
      return;
    }

    setState(() {
      _showError = false;
      _errorMessage = '';
    });
  }

  void _saveChanges() async {
    final String newValue = _controller.text.trim();
    
    setState(() {
      _hasBeenValidated = true;
    });

    if (newValue.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Email harus diisi';
      });
      return;
    }
    
    if (!_isEmailValid(newValue)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Format Email tidak valid';
      });
      return;
    }

    // PERBAIKAN: HAPUS penyimpanan ke SharedPreferences di sini
    // Hanya navigasi ke OTP screen dengan membawa data email baru
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: newValue,
          isForPasswordReset: false, // Tambahkan ini
          onSuccess: () {
            // Callback ini akan dipanggil ketika OTP berhasil diverifikasi
            _updateEmailInSharedPreferences(newValue);
            if (widget.onEmailUpdated != null) {
              widget.onEmailUpdated!();
            }
          },
        ),
      ),
    );
  }

  // Method terpisah untuk update email setelah OTP verified
  void _updateEmailInSharedPreferences(String newEmail) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', newEmail);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = _showError ? Colors.red : Colors.grey;
    final Color borderColor = _showError ? Colors.red : Colors.grey;
    final Color focusedBorderColor = _showError ? Colors.red : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Email'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan Email yang baru:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            
            const SizedBox(height: 15),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: _showError ? Colors.red : null,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: iconColor,
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
                errorText: _showError ? _errorMessage : null,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lanjut', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}