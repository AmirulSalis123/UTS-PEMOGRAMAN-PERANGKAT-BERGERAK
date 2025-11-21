import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  // Method untuk telepon - DIPERBAIKI
  void _launchCaller() async {
    const phoneNumber = '082133960425';
    final Uri callUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    }
  }

  // Method untuk SMS/WhatsApp
  void _launchSMS() async {
    const phone = '6282133960425';
    const message = 'Halo Warung Ajib, saya ingin bertanya';
    final url = 'https://wa.me/$phone?text=${Uri.encodeFull(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
  
  // Method untuk maps
  void _launchMaps() async {
    const url = 'https://maps.app.goo.gl/CTCEgu46yjHAvpz9A';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // Method untuk email
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: '111202214258@mhs.dinus.ac.id',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildSectionHeader('Pusat Bantuan Warung Ajib'),
            const SizedBox(height: 16),
            
            // FAQ Section
            _buildSectionTitle('Pertanyaan Umum'),
            const SizedBox(height: 12),
            
            _buildFAQItem(
              question: 'Bagaimana cara mendaftar akun baru?',
              answer: 'Klik tombol "Daftar" di halaman login, isi data diri Anda, dan verifikasi email/nomor telepon Anda.',
            ),
            
            _buildFAQItem(
              question: 'Saya lupa password, apa yang harus dilakukan?',
              answer: 'Klik "Lupa Password" di halaman login, masukkan email/nomor telepon terdaftar, dan ikuti instruksi verifikasi OTP.',
            ),
            
            _buildFAQItem(
              question: 'Bagaimana cara mengubah data profil?',
              answer: 'Pergi ke menu "Profil Saya" > "Keamanan Akun", lalu pilih data yang ingin diubah.',
            ),
            
            _buildFAQItem(
              question: 'Apakah data saya aman?',
              answer: 'Ya, semua data pribadi Anda dienkripsi dan dilindungi dengan sistem keamanan terbaik.',
            ),
            
            const SizedBox(height: 24),
            
            // Contact Section
            _buildSectionTitle('Hubungi Kami'),
            const SizedBox(height: 12),
            
            _buildContactItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: '111202214258@mhs.dinus.ac.id',
              onTap: _launchEmail,
            ),
            
            _buildContactItem(
              icon: Icons.phone,
              title: 'Telepon',
              subtitle: '+62 821 3396 0425',
              onTap: _launchCaller,
            ),
            
            _buildContactItem(
              icon: Icons.chat,
              title: 'SMS',
              subtitle: '+62 821 3396 0425',
              onTap: _launchSMS,
            ),
            
            _buildContactItem(
              icon: Icons.location_on,
              title: 'Alamat',
              subtitle: 'Jl. Imam Bonjol No.207, Semarang',
              onTap: _launchMaps,
            ),
            
            const SizedBox(height: 24),
            
            // Operating Hours
            _buildSectionTitle('Jam Operasional'),
            const SizedBox(height: 12),
            
            _buildInfoCard(
              'Layanan Pelanggan',
              'Senin - Minggu: 09:00 - 22:00 WIB',
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoCard(
              'SMS',
              'Setiap hari: 24 Jam',
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildSectionTitle('Aksi Cepat'),
            const SizedBox(height: 12),
            
            _buildQuickAction(
              icon: Icons.help_outline,
              title: 'Panduan Penggunaan',
              onTap: () {
                _showComingSoon(context);
              },
            ),
            
            _buildQuickAction(
              icon: Icons.bug_report,
              title: 'Laporkan Masalah',
              onTap: () {
                _showComingSoon(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini akan segera hadir!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.help_center,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Kami siap membantu Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}