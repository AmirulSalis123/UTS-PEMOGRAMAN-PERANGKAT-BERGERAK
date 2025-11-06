import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_verification_screen.dart'; // Import halaman OTP

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController identifierController = TextEditingController();

    Future<void> _sendOtp() async {
      String identifier = identifierController.text.trim();

      if (identifier.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Masukkan Email atau Nomor Telepon Anda.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validasi format jika input adalah email
      if (identifier.contains('@')) {
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(identifier)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Format email tidak valid.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } 
      // Validasi format jika input adalah nomor telepon
      else {
        if (!RegExp(r'^[0-9]+$').hasMatch(identifier)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nomor telepon hanya boleh berisi angka.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (identifier.length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nomor telepon minimal 10 digit.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
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

      if (!isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email/Nomor Telepon tidak terdaftar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP telah dikirim ke $identifier.'),
          backgroundColor: Colors.green,
      ),
    );
      

      // Simpan identifier untuk digunakan di OTP screen
      await prefs.setString('forgotPasswordIdentifier', identifier);

      // Navigasi ke halaman verifikasi OTP
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
      );
    }

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
              decoration: const InputDecoration(
                labelText: 'Email / Nomor Telepon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _sendOtp,
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