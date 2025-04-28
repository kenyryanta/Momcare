// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:pregnancy_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Menampilkan dialog konfirmasi
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content:
                const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Ya, Keluar'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldLogout) {
      // Proses logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus semua data yang tersimpan

      // Navigasi ke halaman login dan hapus semua halaman sebelumnya
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        children: [
          // Header dengan avatar dan nama pengguna
          Container(
            color: AppTheme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ibu Hamil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'ibuhamil@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Menu-menu profil
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Akun Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildProfileMenuItem(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profil',
            onTap: () {},
          ),

          _buildProfileMenuItem(
            context,
            icon: Icons.calendar_today_outlined,
            title: 'Riwayat Pemeriksaan',
            onTap: () {},
          ),

          _buildProfileMenuItem(
            context,
            icon: Icons.favorite_border,
            title: 'Catatan Kesehatan',
            onTap: () {},
          ),

          _buildProfileMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            onTap: () {},
          ),

          const Divider(),

          // Logout button
          _buildProfileMenuItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () => _logout(context),
          ),

          const SizedBox(height: 50),

          // App version
          Center(
            child: Text(
              'Versi Aplikasi 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
