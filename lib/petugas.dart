import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetugasPage extends StatefulWidget {
  const PetugasPage({super.key});

  @override
  _PetugasPageState createState() => _PetugasPageState();
}

class _PetugasPageState extends State<PetugasPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Untuk toggle visibility password
  String _roleSelected = 'petugas'; // Role default saat registrasi
  List<Map<String, dynamic>> petugas = []; // Daftar petugas

  @override
  void initState() {
    super.initState();
    _fetchPetugasFromSupabase(); // Ambil data petugas saat halaman dimuat
  }

  // Fetch petugas dari Supabase
  Future<void> _fetchPetugasFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('user')
          .select('*')
          .order('username', ascending: true);

      if (mounted) {
        setState(() {
          petugas = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  // Tambah petugas baru ke Supabase
  Future<void> _addPetugas(
      String username, String password, String role) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _showMessage('Username dan Password tidak boleh kosong', isError: true);
      return;
    }

    try {
      final existingUser = await Supabase.instance.client
          .from('user')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        _showMessage('Username sudah digunakan', isError: true);
        return;
      }

      await Supabase.instance.client.from('user').insert({
        'username': username,
        'password': password, // Simpan password
        'role': role,
      });

      _showMessage('Petugas berhasil ditambahkan');
      await _fetchPetugasFromSupabase(); // Refresh data
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  // Update petugas di Supabase
  Future<void> _updatePetugas(
      int id, String username, String password, String role) async {
    if (username.trim().isEmpty) {
      _showMessage('Username tidak boleh kosong', isError: true);
      return;
    }

    try {
      await Supabase.instance.client.from('user').update({
        'username': username,
        'password': password, // Update password jika diedit
        'role': role,
      }).eq('id', id);

      _showMessage('Petugas berhasil diperbarui');
      await _fetchPetugasFromSupabase(); // Refresh data
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  // Konfirmasi sebelum menghapus petugas
Future<void> _confirmDeletePetugas(int id) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus petugas ini?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Posisi kiri & kanan
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red, // Warna background merah
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Padding agar proporsional
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePetugas(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Warna background hijau
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10), // Padding agar seimbang
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  // Hapus petugas dari Supabase
  Future<void> _deletePetugas(int id) async {
    try {
      await Supabase.instance.client.from('user').delete().eq('id', id);
      _showMessage('Akun berhasil dihapus');
      _fetchPetugasFromSupabase(); // Update tampilan
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  // Menampilkan pesan
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Menampilkan dialog tambah/edit petugas
  void _showPetugasDialog(
      {int? id, String? username, String? role, String? password}) {
    final TextEditingController usernameController =
        TextEditingController(text: username ?? '');
    final TextEditingController passwordController =
        TextEditingController(text: password ?? '');
    String selectedRole = role ?? 'petugas';
    bool isPasswordVisible =
        false; // Tambahkan variabel untuk kontrol visibilitas password

// Form key untuk validasi
    final _formDialogKey = GlobalKey<FormState>();


      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(id == null ? 'Tambah Petugas' : 'Edit Petugas'),
                content: Form(
                  key: _formDialogKey, // Gunakan FormKey untuk validasi
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: ['admin', 'petugas'].map((role) {
                          return DropdownMenuItem(
                              value: role, child: Text(role));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedRole = value;
                            });
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formDialogKey.currentState!.validate()) {
                            // Jika form valid, simpan data
                            if (id == null) {
                              await _addPetugas(usernameController.text,
                                  passwordController.text, selectedRole);
                            } else {
                              await _updatePetugas(id, usernameController.text,
                                  passwordController.text, selectedRole);
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Text(id == null ? 'Tambah' : 'Simpan'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
        }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: petugas.length,
              itemBuilder: (context, index) {
                final petugasItem = petugas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(petugasItem['username']),
                    subtitle: Text('Role: ${petugasItem['role']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showPetugasDialog(
                            id: petugasItem['id'],
                            username: petugasItem['username'],
                            role: petugasItem['role'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmDeletePetugas(petugasItem['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab3',
            onPressed: () => _showPetugasDialog(),
            child: const Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  


