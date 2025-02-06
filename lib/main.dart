import 'package:flutter/material.dart';
import 'package:pl2_kasir/dashboard.dart';
import 'package:pl2_kasir/penjualan.dart';
import 'package:pl2_kasir/petugas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pl2_kasir/login_page.dart';
import 'package:pl2_kasir/pelanggan.dart';
import 'package:pl2_kasir/riwayat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kasir',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme), // Menetapkan font secara global
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: _getRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const MainPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }

  Future<String?> _getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  final List<Widget> _adminPages = [
    const Dashboard(),
    const PelangganScreen(),
    const PetugasPage(),
  ];

  final List<Widget> _petugasPages = [
    const Dashboard(),
    const PenjualanScreen(),
    const RiwayatPembelianPage(),
    
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Pindahkan user ke halaman login setelah logout
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = role == 'admin' ? _adminPages : _petugasPages;
    final titles = role == 'admin'
        ? ['Produk - Kasir Admin', 'Pelanggan', 'Regristasi Akun Petugas']
        : ['Produk - Kasir Petugas', 'Penjualan', 'Riwayat Pembelian'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex], style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)), // Menampilkan judul halaman sesuai index
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: role == 'admin'
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_reaction_outlined),
                  label: 'Pelanggan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.app_registration_rounded),
                  label: 'Regristasi',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Penjualan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  label: 'Riwayat',
                ),              
                ],
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }
}
