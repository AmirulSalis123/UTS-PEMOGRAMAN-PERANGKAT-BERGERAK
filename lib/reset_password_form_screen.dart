import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// Re-use PasswordField widget dari LoginScreen/RegisterScreen
// Jika Anda memindahkannya ke file terpisah, ganti dengan import yang sesuai.
// Untuk kemudahan, asumsikan PasswordField diakses melalui import atau sudah didefinisikan

class ResetPasswordFormScreen extends StatefulWidget {
  const ResetPasswordFormScreen({super.key});

  @override
  State<ResetPasswordFormScreen> createState() => _ResetPasswordFormScreenState();
}

class _ResetPasswordFormScreenState extends State<ResetPasswordFormScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _submitNewPassword() async {
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru harus diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 6 karakter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password baru tidak cocok.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('password', newPassword); 

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Password berhasil direset!'),
          backgroundColor: Colors.green,
        ),
      );

    // Kembali ke halaman Login, hapus semua riwayat (pushAndRemoveUntil)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ Pastikan widget PasswordField sudah di-import/diakses
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.blue,
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

            // Input Password Baru (Menggunakan PasswordField)
            PasswordField(
              controller: _newPasswordController,
              labelText: 'Password Baru',
              prefixIcon: Icons.lock,
            ),
            
            const SizedBox(height: 15),

            // Input Konfirmasi Password Baru (Menggunakan PasswordField)
            PasswordField(
              controller: _confirmPasswordController,
              labelText: 'Konfirmasi Password Baru',
              prefixIcon: Icons.lock_reset,
            ),
            
            const SizedBox(height: 30),

            // Tombol Submit
            ElevatedButton(
              onPressed: _submitNewPassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan Password Baru', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}