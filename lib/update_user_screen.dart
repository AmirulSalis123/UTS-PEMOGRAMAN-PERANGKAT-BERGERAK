import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;

  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
  });

  @override
  State<PasswordField> createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _isHidden = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _isHidden,
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(widget.prefixIcon),
          suffixIcon: IconButton(
            icon: Icon(
              _isHidden ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => UpdateUserScreenState();
}

class UpdateUserScreenState extends State<UpdateUserScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _updatePassword() async {
    final String currentPassword = _currentPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua data harus diisi'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (newPassword.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password baru minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password baru dan konfirmasi password tidak sama'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String savedPassword = prefs.getString('password') ?? '';

    // Cek password lama
    if (currentPassword != savedPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password lama salah'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Update password
    await prefs.setString('password', newPassword);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Kembali ke halaman keamanan akun
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan password lama dan password baru:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            PasswordField(
              controller: _currentPasswordController,
              labelText: 'Password Saat Ini',
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 12),

            PasswordField(
              controller: _newPasswordController,
              labelText: 'Password Baru',
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 12),

            PasswordField(
              controller: _confirmPasswordController,
              labelText: 'Konfirmasi Password Baru',
              prefixIcon: Icons.lock_reset,
            ),
            const SizedBox(height: 20),

            // Tombol Update Password
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}