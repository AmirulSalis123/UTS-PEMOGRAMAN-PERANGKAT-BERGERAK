import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_user_screen.dart'; 
import 'edit_username_screen.dart';
import 'edit_email_screen.dart';
import 'edit_phone_screen.dart';

class KeamananAkunScreen extends StatefulWidget {
  const KeamananAkunScreen({super.key});

  @override
  State<KeamananAkunScreen> createState() => _KeamananAkunScreenState();
}

class _KeamananAkunScreenState extends State<KeamananAkunScreen> {
  String _username = 'Memuat...';
  String _phone = 'Memuat...';
  String _email = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'user belum diatur';
      _phone = prefs.getString('phone') ?? 'nomor belum diatur'; 
      _email = prefs.getString('email') ?? 'email belum diatur';
    });
  }

  Future<void> _navigateToEditScreen(BuildContext context, {required String field}) async {
    Widget targetScreen;
    String initialValue;
    
    switch (field) {
      case 'Username':
        initialValue = _username;
        targetScreen = EditUsernameScreen(initialValue: initialValue);
        break;
      case 'No. Handphone':
        initialValue = _phone;
        targetScreen = EditPhoneScreen(initialValue: initialValue);
        break;
      case 'Email':
        initialValue = _email;
        targetScreen = EditEmailScreen(initialValue: initialValue);
        break;
      case 'Ganti Password':
        targetScreen = UpdateUserScreen();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    ).then((result) {
      _loadUserData();
    });
  }


  // Widget untuk item yang bisa di-tap (untuk semua field yang bisa diedit)
  Widget _buildTappableItem(BuildContext context, {required String label, required String value, required String fieldKey}) {
    String displayValue = _getDisplayValue(label, value);
    
    return InkWell(
      onTap: () async {
        await _navigateToEditScreen(context, field: fieldKey);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    displayValue, 
                    style: TextStyle(
                      fontSize: 16, 
                      color: _isDefaultValue(value) ? Colors.red : Colors.black
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk mengecek apakah nilai adalah nilai default (belum diatur)
  bool _isDefaultValue(String value) {
    return value == 'nama belum diatur' || 
           value == 'user belum diatur' || 
           value == 'nomor belum diatur' || 
           value == 'email belum diatur';
  }

  // Method untuk mendapatkan nilai yang ditampilkan dengan format yang aman
  String _getDisplayValue(String label, String value) {
    // Jika nilai adalah default, tampilkan apa adanya
    if (_isDefaultValue(value)) {
      return value;
    }
    
    if (value.isEmpty) return '';
    
    switch (label) {
      case 'No. Handphone':
        if (value.length > 4) {
          return '*******${value.substring(value.length - 4)}';
        }
        return value;
      case 'Email':
        if (value.contains('@')) {
          final atIndex = value.indexOf('@');
          if (atIndex > 2) {
            return '${value[0]}******${value.substring(atIndex - 2)}';
          }
          return value;
        }
        return value;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keamanan Akun'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Akun', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black54
                  )
                ),
              ),
              _buildTappableItem(
                context, 
                label: 'Username', 
                value: _username, 
                fieldKey: 'Username'
              ),
              const Divider(height: 1),

              _buildTappableItem(
                context, 
                label: 'No. Handphone', 
                value: _phone, 
                fieldKey: 'No. Handphone'
              ),
              const Divider(height: 1),

              _buildTappableItem(
                context, 
                label: 'Email', 
                value: _email, 
                fieldKey: 'Email'
              ),
              const Divider(height: 1),
              
              const Padding(
                padding: EdgeInsets.only(top: 24.0, left: 16.0, bottom: 8.0),
                child: Text(
                  'Keamanan', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black54
                  )
                ),
              ),

              _buildTappableItem(
                context, 
                label: 'Ganti Password', 
                value: '', 
                fieldKey: 'Ganti Password'
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}