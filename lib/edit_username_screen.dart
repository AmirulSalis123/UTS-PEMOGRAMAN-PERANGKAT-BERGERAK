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
  bool _showError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    // Hanya set nilai jika bukan nilai default "belum diatur"
    if (widget.initialValue != 'user belum diatur') {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      _controller = TextEditingController(); // Kosong jika belum diatur
    }

    // Tambahkan listener untuk menyembunyikan error ketika user mulai mengetik
    _controller.addListener(() {
      if (_showError && _controller.text.trim().isNotEmpty) {
        setState(() {
          _showError = false;
          _errorMessage = '';
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final String newValue = _controller.text.trim();
    
    if (newValue.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Username harus diisi';
      });
      return;
    }
    if (newValue.length < 4) {
      setState(() {
        _showError = true;
        _errorMessage = 'Username minimal 4 karakter';
      });
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Simpan data baru dengan kunci 'username'
    await prefs.setString('username', newValue);
    
    // Tampilkan snackbar sukses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Username berhasil diperbarui!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Kembali ke layar sebelumnya
    Navigator.pop(context, true); 
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna icon berdasarkan ada/tidak error
    final Color iconColor = _showError ? Colors.red : Colors.grey;

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
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: _showError ? Colors.red : null,
                ),
                prefixIcon: Icon(
                  Icons.badge,
                  color: iconColor,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _showError ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _showError ? Colors.red : Colors.blue,
                    width: 2.0,
                  ),
                ),
                errorText: _showError ? _errorMessage : null,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
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
              child: const Text('Simpan', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}