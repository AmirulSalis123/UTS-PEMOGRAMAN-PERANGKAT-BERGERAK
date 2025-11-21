// edit_name_profil_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNameProfilScreen extends StatelessWidget {
  final String fullName;
  
  const EditNameProfilScreen({super.key, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah nama'),
        backgroundColor: Colors.blue,
      ),
      body: EditNameProfilContent(fullName: fullName),
    );
  }
}

class EditNameProfilContent extends StatefulWidget {
  final String fullName;
  
  const EditNameProfilContent({super.key, required this.fullName});

  @override
  State<EditNameProfilContent> createState() => _EditNameProfilContentState();
}

class _EditNameProfilContentState extends State<EditNameProfilContent> {
  late TextEditingController _nameController;
  int _charCount = 0;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    // Jika fullName adalah 'Nama belum diatur', set ke string kosong
    String initialText = widget.fullName == 'Nama belum diatur' ? '' : widget.fullName;
    _nameController = TextEditingController(text: initialText);
    _charCount = initialText.length;
    
    // Tambahkan listener untuk update counter real-time
    _nameController.addListener(() {
      setState(() {
        _charCount = _nameController.text.length;
        // Sembunyikan error ketika user mulai mengetik
        if (_showError && _nameController.text.trim().isNotEmpty) {
          _showError = false;
        }
      });
    });
  }

  void _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', _nameController.text.trim());
    
    if (mounted) {
      Navigator.pop(context, _nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masukkan nama anda :',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _nameController,
            maxLength: 25,
            decoration: InputDecoration(
              labelText: 'Nama anda',
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorText: _showError ? 'Nama harus diisi' : null,
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
              counterText: '',
            ),
          ),
          // Counter yang update real-time
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$_charCount/25',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveName,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}