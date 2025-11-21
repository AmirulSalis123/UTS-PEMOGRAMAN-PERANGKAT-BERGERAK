// profil_saya_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_name_profil_screen.dart';

class ProfilSayaScreen extends StatelessWidget {
  const ProfilSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.blue,
      ),
      body: const ProfilSayaContent(),
    );
  }
}

class ProfilSayaContent extends StatefulWidget {
  const ProfilSayaContent({super.key});

  @override
  State<ProfilSayaContent> createState() => _ProfilSayaContentState();
}

class _ProfilSayaContentState extends State<ProfilSayaContent> {
  String _fullName = 'Memuat...';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _fullName = prefs.getString('fullName') ?? 'Nama belum diatur';
    });
  }

  void _navigateToEditNameProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNameProfilScreen(fullName: _fullName)),
    ).then((value) {
      if (value != null) {
        setState(() {
          _fullName = value;
        });
      }
    });
  }

  // Method untuk menampilkan bottom sheet edit foto profil
  void _showEditPhotoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - DIUBAH dengan tambahan icon close dan hapus
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon Close (X) - pojok kiri
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black54,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    
                    // Text "Foto Profil" - tengah
                    const Text(
                      'Foto Profil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    
                    // Icon Hapus (sampah) - pojok kanan
                    IconButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.black54,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Opsi Kamera
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black54,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Kamera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoFromCamera();
                },
              ),
              
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.grey.shade300,
                  height: 1,
                ),
              ),
              
              // Opsi Galeri
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.black54,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Galeri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhotoFromGallery();
                },
              ),
              
              // Spacer bottom
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Method untuk menampilkan dialog konfirmasi hapus - DIUBAH
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Judul
                const Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Pesan konfirmasi
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Anda yakin ingin menghapus foto profil?',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Tombol BATAL dan HAPUS
                Row(
                  children: [
                    // Tombol BATAL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BATAL',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Tombol HAPUS
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _deleteProfilePhoto();
                          Navigator.pop(context); // Tutup dialog
                          Navigator.pop(context); // Tutup bottom sheet
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'YAKIN',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method untuk menghapus foto profil
  void _deleteProfilePhoto() {
    // Tambahkan logika untuk menghapus foto profil di sini
    print('Foto profil dihapus');
    
    // Tampilkan snackbar untuk feedback dengan warna hijau
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Foto profil berhasil dihapus'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green, // Warna hijau
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Anda bisa menambahkan logika untuk mengupdate UI setelah menghapus foto
    // Contoh: setState(() { _profileImage = null; });
  }

  // Method untuk mengambil foto dari kamera
  void _takePhotoFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (photo != null) {
        // Handle the selected image here
        // Anda bisa menambahkan logika untuk menyimpan foto profil
        print('Foto dari kamera: ${photo.path}');
        // Tambahkan logika untuk update foto profil di UI
        
        // Tampilkan snackbar konfirmasi dengan warna hijau
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto profil berhasil diupdate'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green, // Warna hijau
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error mengambil foto dari kamera: $e');
    }
  }

  // Method untuk memilih foto dari galeri
  void _pickPhotoFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Handle the selected image here
        // Anda bisa menambahkan logika untuk menyimpan foto profil
        print('Foto dari galeri: ${image.path}');
        // Tambahkan logika untuk update foto profil di UI
        
        // Tampilkan snackbar konfirmasi dengan warna hijau
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto profil berhasil diupdate'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green, // Warna hijau
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error memilih foto dari galeri: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Foto Profil - DIUBAH: icon user menjadi putih dengan background biru
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.blue, // Background biru
                  child: const Icon(
                    Icons.person, 
                    size: 50, 
                    color: Colors.white, // Icon user warna putih
                  ),
                ),
              ),
            ],
          ),
          
          // Tombol Edit di bawah foto profil
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              _showEditPhotoBottomSheet(context);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent, // Background benar-benar transparan
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.transparent, // Border transparan
                  width: 0,
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue, // Warna teks biru
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Nama User yang bisa diklik - DIUBAH: border menjadi transparan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () => _navigateToEditNameProfil(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.transparent, // Border dibuat transparan
                    width: 0,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon User
                    const Icon(
                      Icons.person_outline,
                      color: Colors.black54,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    
                    // Nama dan label bersusun
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label "Nama"
                          const Text(
                            'Nama',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // Nama User
                          Text(
                            _fullName,
                            style: TextStyle(
                              fontSize: 16,
                              color: _fullName == 'Nama belum diatur' 
                                  ? Colors.red 
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Icon panah - DIUBAH: dibuat transparan
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.transparent, // Warna icon dibuat transparan
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}