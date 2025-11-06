import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Email dan password harus diisi'),
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
          ),
        );
      }
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    final bool isDefaultUser = (email == 'admin@gmail.com' && password == '123456');
    final bool isRegisteredUser = (prefs.getString('email') == email && 
                                   prefs.getString('password') == password);

    if (isDefaultUser || isRegisteredUser) {
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Email atau password salah'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _forgotPassword() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Warung Ajib',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Alamat Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _forgotPassword, // Panggil fungsi navigasi
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: 'Daftar!',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _navigateToRegister,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}