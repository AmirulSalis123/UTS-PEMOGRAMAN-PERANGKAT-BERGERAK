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
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
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
      obscureText: _isHidden,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: IconButton(
          icon: Icon(
            _isHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: _toggleVisibility,
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
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeStatus();
    _checkForDeletedAccount();
    _autoFillCredentials();
  }

  void _loadRememberMeStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    
    // Auto-fill credentials jika rememberMe true
    if (_rememberMe) {
      String? savedEmail = prefs.getString('savedEmail');
      String? savedPassword = prefs.getString('savedPassword');
      
      if (savedEmail != null && savedPassword != null) {
        setState(() {
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
        });
      }
    }
  }

  void _autoFillCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Cek apakah "Ingatkan Saya" aktif DAN ada saved credentials
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    String? savedEmail = prefs.getString('savedEmail');
    String? savedPassword = prefs.getString('savedPassword');
    
    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
      });
    }
  }

  void _checkForDeletedAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAccountDeleted = prefs.getBool('accountDeleted');
    
    if (isAccountDeleted == true) {
      await prefs.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun Anda telah dihapus. Silakan daftar ulang.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _login() async {
    if (_isLoading) return;

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackBar('Format email tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      bool? isAccountDeleted = prefs.getBool('accountDeleted');
      if (isAccountDeleted == true) {
        _showErrorSnackBar('Akun telah dihapus. Tidak dapat login.');
        return;
      }

      final bool isDefaultUser = (email == 'admin@gmail.com' && password == '123456');
      final bool isRegisteredUser = (prefs.getString('email') == email && 
                                    prefs.getString('password') == password);

      if (isDefaultUser || isRegisteredUser) {
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);
        await prefs.setBool('rememberMe', _rememberMe);

        // Simpan credentials jika "Ingatkan Saya" dipilih
        if (_rememberMe) {
          await prefs.setString('savedEmail', email);
          await prefs.setString('savedPassword', password);
        } else {
          // Jika tidak dipilih, hapus saved credentials
          await prefs.remove('savedEmail');
          await prefs.remove('savedPassword');
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        _showErrorSnackBar('Email atau password salah');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur login dengan Google akan segera hadir!'),
        backgroundColor: Colors.orange,
      ),
    );
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

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
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
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: _isLoading ? null : _toggleRememberMe,
                    activeColor: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _isLoading ? null : () {
                      _toggleRememberMe(!_rememberMe);
                    },
                    child: Text(
                      'Ingatkan Saya',
                      style: TextStyle(
                        color: _isLoading ? Colors.grey : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!_isLoading)
                    GestureDetector(
                      onTap: _forgotPassword,
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _isLoading ? Colors.grey : Colors.blue,
              ),
              child: _isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Login', 
                      style: TextStyle(fontSize: 16, color: Colors.white)
                    ),
            ),
            const SizedBox(height: 10),

            if (!_isLoading) ...[
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'atau',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: _isLoading ? null : _loginWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/google_icon.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Masuk dengan Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

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
                      recognizer: TapGestureRecognizer()..onTap = _isLoading ? null : _navigateToRegister,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}