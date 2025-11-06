// File: edit_nama_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNamaScreen extends StatefulWidget {
  final String initialValue;

  const EditNamaScreen({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<EditNamaScreen> createState() => _EditNamaScreenState();
}

class _EditNamaScreenState extends State<EditNamaScreen> {
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
        _showSnackbar('Nama Lengkap tidak boleh kosong.', Colors.red);
        return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Simpan data baru dengan kunci 'fullName'
    await prefs.setString('fullName', newValue);
    
    _showSnackbar('Nama Lengkap berhasil diperbarui!', Colors.green);
    
    // Kembali ke layar sebelumnya
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Nama Lengkap'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan Nama Lengkap yang baru:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            // Kolom Input Nama Lengkap
            TextField(
              controller: _controller,
              keyboardType: TextInputType.name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap Baru',
                prefixIcon: Icon(Icons.person_outline),
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
              child: const Text('Simpan Nama Lengkap', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}