// File: edit_phone_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPhoneScreen extends StatefulWidget {
  final String initialValue;

  const EditPhoneScreen({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
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

  void _saveChanges() async {
    final String newValue = _controller.text.trim();
    
    if (newValue.isEmpty || newValue.length < 10) {
        _showSnackbar('Nomor Handphone tidak valid.', Colors.red);
        return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', newValue); 
    
    _showSnackbar('No. Handphone berhasil diperbarui!', Colors.green);
    
    Navigator.pop(context); 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah No. Handphone'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan Nomor Handphone yang baru:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'No. Handphone',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}