import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'reset_password_form_screen.dart'; // Import halaman reset password

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  
  // ⚠️ KODE OTP DEFAULT (HARDCODED)
  static const String defaultOtp = '1111';

final defaultPinTheme = PinTheme(
    width: 50,
    height: 50,
    textStyle: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black), // Border luar kotak
      borderRadius: BorderRadius.circular(5),
    ),
  );

  void _verifyOtp() {
    final String enteredOtp = _otpController.text.trim();

    if (enteredOtp == defaultOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordFormScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP salah. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  void _resendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode OTP telah dikirim ulang.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Masukkan 4 digit kode verifikasi yang telah dikirimkan.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Kolom Input OTP
            Center(
              child: Pinput(
                length: 4,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.blue, width: 2), // Warna saat fokus
                ),
                submittedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.green), // Warna saat sudah terisi
                ),
                showCursor: true,
                onCompleted: (pin) => _verifyOtp(), // Verifikasi otomatis setelah 4 digit terisi
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Verifikasi
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Verifikasi', style: TextStyle(fontSize: 16)),
            ),
            
            const SizedBox(height: 20),

            // Fitur Kirim Ulang OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tidak menerima kode?'),
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Kirim Ulang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}