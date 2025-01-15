import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final response =
          await Supabase.instance.client.from('produk').select('*');

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
        });

        _namaProdukController.clear();
        _hargaController.clear();
        _stokController.clear();

        await _fetchProdukFromSupabase(); // Refresh data produk setelah menambah

        Navigator.pop(context);
        
        if (response != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan')),
          );

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
        
      }
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
                  TextFormField(
                    controller: _namaProdukController,
                    decoration: InputDecoration(
                        labelText: 'Nama Produk',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                        )),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama produk tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _hargaController,
                    decoration: InputDecoration(
                        labelText: 'Harga',
                        prefixText: 'Rp ',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                        )),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga tidak boleh kosong';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan harga dengan benar';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _stokController,
                    decoration: InputDecoration(
                        labelText: 'Stok',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 15,
                        )),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stok tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan stok dengan benar';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addProdukToSupabase();
                  }
                },
                child: const Text('Tambah'),
              )
            ],
          );
        });
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
              // const Icon(Icons.store_mall_directory_outlined,
              //     color: Colors.blue),
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
                onPressed: () {
                  //Aksi
                },
                icon: const Icon(Icons.notifications_active_outlined,
                    color: Colors.blue))
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
          selectedLabelStyle:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 5,
            childAspectRatio: 2,
          ),
          itemCount: produk.length,
          itemBuilder: (context, index) {
            final item = produk[index];
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['nama_produk'] ?? 'Unknown',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Harga: Rp ${item['harga']}',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  Text('Stok: ${item['stok']}',
                      style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            );
          },
        ));
  }
}
