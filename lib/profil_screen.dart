import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profil_saya_screen.dart';
import 'keamanan_akun_screen.dart';
import 'login_screen.dart';
import 'bantuan_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToKeamananAkun(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const KeamananAkunScreen()),
    );
  }

  void _navigateToProfilSaya(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilSayaScreen()),
    );
  }
  
  void _navigateToBantuan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BantuanScreen()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                  'Konfirmasi keluar',
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
                        text: 'Anda yakin ingin keluar dari aplikasi Warung Ajib?',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Tombol BATAL dan YAKIN
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
                    
                    // Tombol YAKIN
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                        final SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          await prefs.setBool('isLoggedIn', false);

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
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

  void _showDeleteAccountDialog(BuildContext context) {
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
                  'Konfirmasi hapus akun',
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
                        text: 'Anda yakin ingin ',
                      ),
                      TextSpan(
                        text: 'MENGHAPUS ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'akun aplikasi ',
                      ),
                      TextSpan(
                        text: 'Warung Ajib',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Tombol BATAL dan YAKIN
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
                    
                    // Tombol YAKIN
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                        final SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          await prefs.setBool('accountDeleted', true);
                          await prefs.remove('fullName');
                          await prefs.remove('username');
                          await prefs.remove('phone');
                          await prefs.remove('email');
                          await prefs.remove('password');

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false,
                            );
                          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Column(
              children: [
                _buildMenuTile(
                  icon: Icons.person_outline,
                  title: 'PROFIL SAYA',
                  onTap: () => _navigateToProfilSaya(context),
                ),
                const SizedBox(height: 10),
                _buildMenuTile(
                  icon: Icons.lock_outline,
                  title: 'KEAMANAN AKUN',
                  onTap: () => _navigateToKeamananAkun(context),
                ),
                const SizedBox(height: 10),
                _buildMenuTile(
                  icon: Icons.help_outline,
                  title: 'BANTUAN',
                  onTap: () => _navigateToBantuan(context),
                ),
                const SizedBox(height: 10),
                _buildMenuTile(
                  icon: Icons.logout,
                  title: 'KELUAR',
                  onTap: () => _showLogoutDialog(context), 
                ),
                const SizedBox(height: 10),
                _buildMenuTile(
                  icon: Icons.delete_forever,
                  title: 'HAPUS AKUN',
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
  }) {
    const Color iconColor = Colors.black87; 
    const Color textColor = Colors.black; 
    const Color arrowColor = Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: arrowColor),
        onTap: onTap,
      ),
    );
  }
}