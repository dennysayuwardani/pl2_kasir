import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'logout_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  int _currentIndex = 0; // Menyimpan indeks tombol yang aktif
  List<Map<String, dynamic>> produk = [];

  @override
  void initState() {
    super.initState();
    _fetchProdukFromSupabase(); // Ambil data produk saat inisialisasi
  }

  Future<void> _fetchProdukFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select('*')
          .order('produk_id', ascending: true);

      if (response != null) {
        setState(() {
          produk = List<Map<String, dynamic>>.from(response);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data produk.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _addProdukToSupabase() async {
    if (_formKey.currentState!.validate()) {
      final nama = _namaProdukController.text;
      final harga = double.tryParse(_hargaController.text) ?? 0.0;
      final stok = int.tryParse(_stokController.text) ?? 0;

      try {
        final response = await Supabase.instance.client.from('produk').insert({
          'nama_produk': nama,
          'harga': harga,
          'stok': stok,
        }).select();

        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan')),
          );
          _namaProdukController.clear();
          _hargaController.clear();
          _stokController.clear();

          await _fetchProdukFromSupabase(); // Refresh data produk setelah menambah

          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _updateProdukToSupabase(int id) async {
    final nama_produk = _namaProdukController.text;
    final harga = double.tryParse(_hargaController.text) ?? 0.0;
    final stok = int.tryParse(_stokController.text) ?? 0;

    try {
      await Supabase.instance.client.from('produk').update({
        'nama_produk': nama_produk,
        'harga': harga,
        'stok': stok,
      }).eq('produk_id', id); // Update berdasarkan ID

      _namaProdukController.clear();
      _hargaController.clear();
      _stokController.clear();

      await _fetchProdukFromSupabase(); // Refresh data produk
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _deleteProdukFromSupabase(int id) async {
    try {
      await Supabase.instance.client
          .from('produk')
          .delete()
          .eq('produk_id', id); // Hapus berdasarkan ID
      await _fetchProdukFromSupabase(); // Refresh data produk

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void _showAddProdukDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Tambah Produk',
            style: GoogleFonts.poppins(fontSize: 20),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                controller: _namaProdukController,
                label: 'Nama Produk',
                validator: (value) =>
                    value!.isEmpty ? 'Nama produk tidak boleh kosong' : null,
              ),
                _buildInputField(
                controller: _hargaController,
                label: 'Harga',
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
                validator: (value) {
                  if (value!.isEmpty) return 'Harga tidak boleh kosong';
                  return double.tryParse(value) == null
                      ? 'Masukkan harga dengan benar'
                      : null;
                },
              ),
                _buildInputField(
                controller: _stokController,
                label: 'Stok',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Stok tidak boleh kosong';
                  return int.tryParse(value) == null
                      ? 'Masukkan stok dengan benar'
                      : null;
                },
              ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addProdukToSupabase();
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required String? Function(String?) validator,
  TextInputType keyboardType = TextInputType.text,
  String? prefixText,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefixText,
      labelStyle: GoogleFonts.poppins(fontSize: 15),
    ),
    keyboardType: keyboardType,
    validator: validator,
  );
}


void _showEditProdukDialog(Map<String, dynamic> produk) {
  _namaProdukController.text = produk['nama_produk'];
  _hargaController.text = produk['harga'].toString();
  _stokController.text = produk['stok'].toString();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Edit Produk',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(
                controller: _namaProdukController,
                label: 'Nama Produk',
                validator: (value) =>
                    value!.isEmpty ? 'Nama produk tidak boleh kosong' : null,
              ),
              _buildInputField(
                controller: _hargaController,
                label: 'Harga',
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
                validator: (value) {
                  if (value!.isEmpty) return 'Harga tidak boleh kosong';
                  return double.tryParse(value) == null
                      ? 'Masukkan harga dengan benar'
                      : null;
                },
              ),
              _buildInputField(
                controller: _stokController,
                label: 'Stok',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Stok tidak boleh kosong';
                  return int.tryParse(value) == null
                      ? 'Masukkan stok dengan benar'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateProdukToSupabase(produk['produk_id']);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

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
              Text('Kasir',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  )),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LogoutPage()));
            },
          ),
        ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddProdukDialog,
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex, // Indeks tombol yang aktif
          selectedItemColor: Colors.blue, // Warna tombol aktif
          unselectedItemColor: Colors.grey, // Warna tombol tidak aktif
          onTap: _onTap, // Callback saat tombol diklik
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined), label: 'Produk'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long), label: 'Transaksi'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined), label: 'Profil'),
          ],
          selectedLabelStyle:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 10,
            childAspectRatio: 5,
          ),
          itemCount: produk.length,
          itemBuilder: (context, index) {
            final item = produk[index];
            return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['nama_produk'] ?? 'Unknown',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Harga: Rp ${item['harga']}',
                            style: GoogleFonts.poppins(fontSize: 14)),
                        Text('Stok: ${item['stok']}',
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditProdukDialog(item); // Panggil dialog edit
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteProdukFromSupabase(
                              item['produk_id']); // Panggil hapus
                        },
                      ),
                    ],
                  ),
                ]));
          },
        ));
  }
}
