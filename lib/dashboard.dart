import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0; // Menyimpan indeks tombol yang aktif

  void _onTap(int index) {
    setState(() {
      _currentIndex = index; // Memperbarui indeks aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.store_mall_directory_outlined),
            Text('Kasir',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          ],
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed: () {
            //Aksi
          }, icon: const Icon(Icons.notifications_active_outlined))
        ],
      ),
      body: Center(
        child: Text(
          _currentIndex == 0
              ? 'Produk'
              : _currentIndex == 1
                  ? 'Transaksi'
                  : 'Profil',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Indeks tombol yang aktif
        selectedItemColor: Colors.blue, // Warna tombol aktif
        unselectedItemColor: Colors.grey, // Warna tombol tidak aktif
        onTap: _onTap, // Callback saat tombol diklik
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profil',
          ),
        ],
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
      )
    
    );
  }
}
