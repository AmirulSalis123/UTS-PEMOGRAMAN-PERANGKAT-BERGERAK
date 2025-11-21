import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ResetPasswordFormScreen extends StatefulWidget {
  const ResetPasswordFormScreen({super.key});

  @override
  State<ResetPasswordFormScreen> createState() => _ResetPasswordFormScreenState();
}

class _ResetPasswordFormScreenState extends State<ResetPasswordFormScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _newPasswordError;
  String? _confirmPasswordError;
  
  // PERBAIKAN: Ubah nama variabel untuk konsistensi
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  void _submitNewPassword() async {
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Reset error messages
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;

    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = 'Password baru harus diisi.';
      });
      hasError = true;
    } else if (newPassword.length < 6) {
      setState(() {
        _newPasswordError = 'Password minimal 6 karakter.';
      });
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Konfirmasi password harus diisi.';
      });
      hasError = true;
    } else if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Password tidak sama.';
      });
      hasError = true;
    }

    if (hasError) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('password', newPassword); 

    // Simpan context sebelum async gap
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password berhasil direset!'),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke halaman Login, hapus semua riwayat (pushAndRemoveUntil)
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordHidden = !_isNewPasswordHidden;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Kembali ke halaman OTP verification
        Navigator.pop(context);
        return false; // Mencegah default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Kembali ke halaman OTP verification
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Masukkan password baru Anda.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Input Password Baru
              _buildPasswordField(
                controller: _newPasswordController,
                labelText: 'Password Baru',
                prefixIcon: Icons.lock,
                errorText: _newPasswordError,
                isPasswordHidden: _isNewPasswordHidden, // PERBAIKAN: parameter diubah
                onToggleVisibility: _toggleNewPasswordVisibility,
              ),
              
              // Jarak yang menyesuaikan berdasarkan ada/tidak error di password baru
              SizedBox(height: _newPasswordError != null ? 20.0 : 15.0),

              // Input Konfirmasi Password Baru
              _buildPasswordField(
                controller: _confirmPasswordController,
                labelText: 'Konfirmasi Password Baru',
                prefixIcon: Icons.lock_reset,
                errorText: _confirmPasswordError,
                isPasswordHidden: _isConfirmPasswordHidden, // PERBAIKAN: parameter diubah
                onToggleVisibility: _toggleConfirmPasswordVisibility,
              ),
              
              // Jarak yang menyesuaikan berdasarkan ada/tidak error di konfirmasi password
              SizedBox(height: _confirmPasswordError != null ? 35.0 : 30.0),

              const SizedBox(height: 30),

              // Tombol Submit
              ElevatedButton(
                onPressed: _submitNewPassword,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PERBAIKAN: Custom method dengan logika yang konsisten
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? errorText,
    required bool isPasswordHidden, // PERBAIKAN: parameter diubah
    required VoidCallback onToggleVisibility,
  }) {
    // Tentukan warna icon berdasarkan ada/tidak error
    final Color iconColor = errorText != null ? Colors.red : Colors.grey;

    return TextField(
      controller: controller,
      obscureText: isPasswordHidden, // PERBAIKAN: langsung tanpa negasi
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: errorText != null ? Colors.red : null,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: iconColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            // PERBAIKAN: Logika icon yang benar
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: iconColor,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorText != null ? Colors.red : Colors.blue,
            width: 2.0,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        errorText: errorText,
        errorMaxLines: 2, // Agar error text tidak terlalu panjang
      ),
    );
  }
}