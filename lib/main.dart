import 'package:flutter/material.dart';
import 'package:pl2_kasir/dashboard.dart';
import 'package:pl2_kasir/profile.dart';
import 'package:pl2_kasir/penjualan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pl2_kasir/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pl2_kasir/pelanggan.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://kqcgmnzgryawkdbkfpyn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxY2dtbnpncnlhd2tkYmtmcHluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzIwNjgsImV4cCI6MjA1MTcwODA2OH0.2CC1hFsfGjYs3q1L0GkfHPHyeAp6FSjq2t2ZhyxgWb0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kasir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Indeks awal untuk navigasi bawah

  final List<Widget> _pages = [
    const Dashboard(), // Halaman Dashboard
    const PenjualanScreen(), // Halaman Transaksi
    const PelangganScreen(), // Halaman Pelanggan
    const ProfilePage(), // Halaman Profil
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Tampilkan halaman berdasarkan indeks
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Ubah indeks saat tombol diklik
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Penjualan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_reaction_outlined),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profil',
          ),
        ],
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
      ),
    );
  }
}
