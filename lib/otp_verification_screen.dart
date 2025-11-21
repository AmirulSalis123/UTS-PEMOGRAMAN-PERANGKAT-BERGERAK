import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'reset_password_form_screen.dart';
import 'keamanan_akun_screen.dart';
import 'bantuan_screen.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onSuccess;
  final bool isForPasswordReset;
  final bool isSms;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.onSuccess,
    this.isForPasswordReset = false,
    this.isSms = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  static const String defaultOtp = '1111';
  int _countdown = 0;
  Timer? _timer;
  String? _errorText;

  PinTheme _getPinTheme(Color color, [double width = 1]) {
    return PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _verifyOtp() {
    final String enteredOtp = _otpController.text.trim();

    setState(() {
      _errorText = null;
    });

    if (enteredOtp.isEmpty) {
      setState(() {
        _errorText = 'Kode OTP harus diisi';
      });
      return;
    }

    if (enteredOtp == defaultOtp) {
      // PERBAIKAN: Panggil onSuccess terlebih dahulu
      if (widget.onSuccess != null) {
        widget.onSuccess!(); // Ini akan menyimpan data ke SharedPreferences
      }

      // Tampilkan notifikasi sukses
      if (!widget.isForPasswordReset) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isSms 
                ? 'Nomor handphone telah diperbarui.'
                : 'Email telah diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // PERBAIKAN: Tunggu sebentar sebelum navigasi agar notifikasi terlihat
      Future.delayed(const Duration(milliseconds: 500), () {
        if (widget.isForPasswordReset) {
          // Untuk reset password
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ResetPasswordFormScreen()),
          );
        } else {
          // Untuk edit email/phone - kembali ke KeamananAkunScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const KeamananAkunScreen()),
            (route) => false,
          );
        }
      });

    } else {
      setState(() {
        _errorText = 'Kode OTP salah';
      });
    }
  }

  void _resendOtp() {
    if (_countdown > 0) return;

    setState(() {
      _errorText = null;
    });

    Future.microtask(() {
      setState(() {
        _countdown = 60;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
          }
        });
      });
    });

    Future.microtask(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP telah dikirim ulang'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  String _getMessageText() {
    if (widget.isSms) {
      return 'Kode verifikasi (OTP) telah dikirim melalui SMS';
    } else {
      return 'Kode verifikasi (OTP) telah dikirim melalui Email';
    }
  }

  void _navigateToBantuan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BantuanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _errorText != null ? Colors.red : Colors.black;
    final Color focusedBorderColor = _errorText != null ? Colors.red : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Masukkan Kode Verifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateToBantuan(context),
            child: const Text(
              'Bantuan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              _getMessageText(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            Column(
              children: [
                Center(
                  child: Pinput(
                    length: 4,
                    controller: _otpController,
                    defaultPinTheme: _getPinTheme(borderColor),
                    focusedPinTheme: _getPinTheme(focusedBorderColor, 2),
                    submittedPinTheme: _getPinTheme(Colors.blue),
                    errorPinTheme: _getPinTheme(Colors.red, 2),
                    showCursor: true,
                    onCompleted: (pin) => _verifyOtp(),
                    onChanged: (value) {
                      if (_errorText != null) {
                        setState(() {
                          _errorText = null;
                        });
                      }
                    },
                  ),
                ),
                
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 30),
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
            
            _countdown > 0
                ? Text(
                    'Mohon tunggu $_countdown detik untuk mengirim ulang',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tidak menerima kode?'),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _resendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Kirim Ulang',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}