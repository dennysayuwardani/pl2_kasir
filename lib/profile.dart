import 'package:flutter/material.dart';
import 'package:pl2_kasir/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 2; // Indeks halaman Profil sebagai default
  String _username = ''; // Variabel untuk menyimpan username
  String _role = ''; // Variabel untuk menyimpan role

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Kunci form untuk validasi

  // Menyimpan error message untuk validasi
  String _usernameError = '';
  String _passwordError = '';
  String _roleSelected = 'petugas'; // Role default saat registrasi

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Panggil fungsi untuk memuat data username dan role
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
      _role = prefs.getString('role') ?? 'Unknown';
    });
  }

  void _onTap(int index) {
    _currentIndex = index;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard'); // Ke Dashboard
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/transaksi'); // Jika ada halaman transaksi
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

      // Hapus data di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

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

  Future<void> _registerUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    setState(() {
      // Reset error messages
      _usernameError = '';
      _passwordError = '';
    });

    // Validasi form
    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username tidak boleh kosong';
      });
    }
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password tidak boleh kosong';
      });
    }

    // Jika ada error, jangan lanjutkan
    if (_usernameError.isNotEmpty || _passwordError.isNotEmpty) {
      return;
    }

try {
      // Mengecek apakah username sudah ada
      final response = await Supabase.instance.client
          .from('user')
          .select()
          .eq('username', username)
          .single();

      if (response != null) {
        // Jika ada username yang sama
        setState(() {
          _usernameError = 'Username sudah digunakan';
        });
        return;
      }

      // Melakukan registrasi akun baru jika username belum ada
      final newUser = await Supabase.instance.client.from('user').insert([
        {
          'username': username,
          'password': password,
          'role': _role,  // Role yang dipilih
        }
      ]).select().single();

      if (newUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Akun berhasil dibuat'), backgroundColor: Colors.green));
        Navigator.of(context).pop(); // Menutup form setelah berhasil
      } else {
        setState(() {
          _usernameError = 'Gagal membuat akun';
        });
      }
    } catch (e) {
      setState(() {
        _usernameError = 'Terjadi kesalahan: $e';
      });
    }
  }
  // Menampilkan dialog untuk menambah atau mengedit akun admin dan petugas
  void _showUserDialog({Map<String, dynamic>? userData}) {
    _usernameController.text = userData?['username'] ?? '';
    _passwordController.text = '';
    _roleSelected = userData?['role'] ?? 'petugas';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(userData == null ? 'Tambah Pengguna' : 'Edit Pengguna'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(controller: _usernameController, label: 'Username'),
                _buildInputField(controller: _passwordController, label: 'Password', obscureText: true),
                DropdownButtonFormField<String>(
                  value: _roleSelected,
                  onChanged: (value) {
                    setState(() {
                      _roleSelected = value!;
                    });
                  },
                  items: ['admin', 'petugas'].map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _registerUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
    );
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
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama : $_username',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Role : $_role',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Registrasi Akun Baru (Hanya untuk admin)
            if (_role == 'admin') ...[
              GestureDetector(
                onTap: () {
                  // Menampilkan form untuk registrasi akun baru
                  _showUserDialog();
                },
                child: const Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue, size: 30),
                    SizedBox(width: 16),
                    Text(
                      'Registrasi Akun Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Logout
            GestureDetector(
              onTap: () {
                _logout(context);
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.blue, size: 30),
                  SizedBox(width: 16),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
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
