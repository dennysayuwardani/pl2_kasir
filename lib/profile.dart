import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pl2_kasir/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2; // Indeks halaman Profil sebagai default

  void _onTap(int index) {
    _currentIndex = index;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard'); // Ke Dashboard
        break;
      case 1:
        Navigator.pushReplacementNamed(
            context, '/transaksi'); // Jika ada halaman transaksi
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile'); // Tetap di Profil
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Proses logout
      await Supabase.instance.client.auth.signOut();

      // Arahkan ke halaman login setelah logout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Icon dan Nama
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama :',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Role :',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Registrasi Akun Baru
            GestureDetector(
              onTap: () {
                // Tambahkan logika untuk navigasi ke halaman Registrasi
              },
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.blue, size: 30),
                  const SizedBox(width: 16),
                  Text(
                    'Registrasi Akun Baru',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            GestureDetector(
              onTap: () {
                _logout(context);
              },
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Colors.blue, size: 30),
                  const SizedBox(width: 16),
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
}
