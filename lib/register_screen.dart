import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  // State untuk mengontrol visibilitas password
  bool _isHidden = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _isHidden, // Terikat pada state Show/Hide
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        // Tombol Suffix (ikon mata) untuk mengubah state
        suffixIcon: IconButton(
          icon: Icon(
            _isHidden ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: _toggleVisibility, // Mengubah state saat diklik
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _register() async {
    final String fullName = _fullNameController.text.trim();
    final String username = _usernameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi form
    if (fullName.isEmpty || 
        username.isEmpty || 
        phone.isEmpty || 
        email.isEmpty || 
        password.isEmpty || 
        confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Semua data harus diisi'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Validasi format email
    if (!email.contains('@') || !email.contains('.')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Format email tidak valid'),
            backgroundColor: Colors.red,
            ) ,
          );
      }
      return;
    }

    // Validasi format nomor telepon (minimal 10 digit, hanya angka)
    if (phone.length < 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Nomor telepon harus minimal 10 digit dan hanya berisi angka'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Password dan konfirmasi password tidak sama'),
              backgroundColor: Colors.red,
            ),
          );
      }
      return;
    }

    if (password.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Password minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Simpan data user
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('fullName', fullName);
    await prefs.setString('username', username);
    await prefs.setString('phone', phone);
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: const Text('Registrasi berhasil!'),
        backgroundColor: Colors.green,
      ),
    );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void _backToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToLogin,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
              
              // Nama Lengkap
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              
              // Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              // Nomor Telepon
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password
              PasswordField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 16),
              
              // Konfirmasi Password
              PasswordField(
                controller: _confirmPasswordController,
                labelText: 'Konfirmasi Password',
                prefixIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 30),
              
              // Tombol Daftar
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Daftar', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              
              // Link ke Login
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'Login!',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _backToLogin,
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