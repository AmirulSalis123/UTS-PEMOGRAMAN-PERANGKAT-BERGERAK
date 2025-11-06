// File: edit_username_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUsernameScreen extends StatefulWidget {
  final String initialValue;

  const EditUsernameScreen({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<EditUsernameScreen> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveChanges() async {
    final String newValue = _controller.text.trim();
    
    if (newValue.isEmpty) {
        _showSnackbar('Username tidak boleh kosong.', Colors.red);
        return;
    }
    if (newValue.length < 4) {
        _showSnackbar('Username minimal 4 karakter.', Colors.red);
        return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Simpan data baru dengan kunci 'username'
    await prefs.setString('username', newValue);
    
    _showSnackbar('Username berhasil diperbarui!', Colors.green);
    
    // Kembali ke layar sebelumnya
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Username'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan Username yang baru:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            // Kolom Input Username
            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Username Baru',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 30),

            // Tombol Simpan
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan Username', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}