import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_verification_screen.dart';

class EditPhoneScreen extends StatefulWidget {
  final String initialValue;
  final VoidCallback? onPhoneUpdated;

  const EditPhoneScreen({
    Key? key,
    required this.initialValue,
    this.onPhoneUpdated,
  }) : super(key: key);

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  late TextEditingController _controller;
  bool _showError = false;
  String _errorMessage = '';
  bool _hasBeenValidated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != 'nomor belum diatur') {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      _controller = TextEditingController();
    }

    _controller.addListener(() {
      if (_hasBeenValidated) {
        _validatePhoneRealTime(_controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isPhoneValid(String phone) {
    // Hapus karakter non-digit
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Validasi panjang
    if (cleanPhone.length < 10 || cleanPhone.length > 14) {
      return false;
    }

    final validPrefixes = [
      '0811', '0812', '0813', '0821', '0822', '0823', // Telkomsel
      '0851', '0852', '0853', // Indosat
      '0877', '0878', '0879', // XL
      '0895', '0896', '0897', '0898', '0899', // Three
      '0881', '0882', '0883', '0884', '0885', '0886', '0887', '0888', '0889', // Smartfren
      '0814', '0815', '0816', '0817', '0818', '0819', // Indosat
      '0855', '0856', '0857', '0858', // Indosat
      '0859', // Indosat
      '0909', // Nex Parabola
      '0921', '0922', '0923', // Halo
      '0951', '0952', '0953', '0954', '0955', // By.U
    ];

    // Cek apakah nomor dimulai dengan prefix yang valid
    for (final prefix in validPrefixes) {
      if (cleanPhone.startsWith(prefix)) {
        return true;
      }
    }

    return false;
  }

  void _validatePhoneRealTime(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone harus diisi';
      });
      return;
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone hanya boleh berisi angka';
      });
      return;
    }

    if (cleanPhone.length < 10) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone minimal 10 digit';
      });
      return;
    }

    if (cleanPhone.length > 14) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone maksimal 14 digit';
      });
      return;
    }

    if (!_isPhoneValid(cleanPhone)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Format nomor tidak valid!';
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
    final cleanPhone = newValue.replaceAll(RegExp(r'[^\d]'), '');
    
    setState(() {
      _hasBeenValidated = true;
    });

    if (cleanPhone.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone harus diisi';
      });
      return;
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanPhone)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone hanya boleh berisi angka';
      });
      return;
    }

    if (cleanPhone.length < 10) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone minimal 10 digit';
      });
      return;
    }

    if (cleanPhone.length > 14) {
      setState(() {
        _showError = true;
        _errorMessage = 'Nomor Handphone maksimal 14 digit';
      });
      return;
    }

    if (!_isPhoneValid(cleanPhone)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Format nomor tidak valid!';
      });
      return;
    }

    // PERBAIKAN: HAPUS penyimpanan ke SharedPreferences di sini
    // Hanya navigasi ke OTP screen dengan membawa data nomor baru
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: cleanPhone,
          isSms: true,
          onSuccess: () {
            // Callback ini akan dipanggil ketika OTP berhasil diverifikasi
            _updatePhoneInSharedPreferences(cleanPhone);
            if (widget.onPhoneUpdated != null) {
              widget.onPhoneUpdated!();
            }
          },
        ),
      ),
    );
  }

  // Method terpisah untuk update nomor telepon setelah OTP verified
  void _updatePhoneInSharedPreferences(String newPhone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', newPhone);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = _showError ? Colors.red : Colors.grey;
    final Color borderColor = _showError ? Colors.red : Colors.grey;
    final Color focusedBorderColor = _showError ? Colors.red : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah No. Handphone'),
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
              'Masukkan Nomor Handphone yang baru:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'No. Handphone',
                labelStyle: TextStyle(
                  color: _showError ? Colors.red : null,
                ),
                prefixIcon: Icon(
                  Icons.phone,
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