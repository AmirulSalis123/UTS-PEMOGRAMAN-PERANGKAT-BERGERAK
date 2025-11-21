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
            _isHidden ? Icons.visibility_off : Icons.visibility,
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Validasi email dengan TLD yang diperbolehkan
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

  void _register() async {
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi form
    if (username.isEmpty ||  
        email.isEmpty || 
        password.isEmpty || 
        confirmPassword.isEmpty) {
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

    // Validasi format email dengan filter TLD
    if (!_isEmailValid(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format email tidak valid'),
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
            content: Text('Password dan konfirmasi password tidak sama'),
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
            content: Text('Password minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Simpan data user
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('password', password);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil!'),
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