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
  List<Map<String, dynamic>> produk = [];

  @override
  void initState() {
    super.initState();
    _fetchProdukFromSupabase();
  }

  Future<void> _fetchProdukFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select('*')
          .order('produk_id', ascending: true);
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  Future<void> _addProdukToSupabase() async {
    final nama = _namaProdukController.text;
    final harga = double.tryParse(_hargaController.text) ?? 0.0;
    final stok = int.tryParse(_stokController.text) ?? 0;

    try {
      await Supabase.instance.client.from('produk').insert({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok,
      });
      _showMessage('Produk berhasil ditambahkan');
      _fetchProdukFromSupabase();
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  Future<void> _updateProdukToSupabase(int id) async {
    final nama = _namaProdukController.text;
    final harga = double.tryParse(_hargaController.text) ?? 0.0;
    final stok = int.tryParse(_stokController.text) ?? 0;

    try {
      await Supabase.instance.client.from('produk').update({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok,
      }).eq('produk_id', id);
      _showMessage('Produk berhasil diperbarui');
      _fetchProdukFromSupabase();
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  Future<void> _deleteProdukFromSupabase(int id) async {
    try {
      await Supabase.instance.client
          .from('produk')
          .delete()
          .eq('produk_id', id);
      _showMessage('Produk berhasil dihapus');
      _fetchProdukFromSupabase();
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showProdukDialog({
    required String title,
    required VoidCallback onConfirm,
    Map<String, dynamic>? produk,
  }) {
    if (produk != null) {
      _namaProdukController.text = produk['nama_produk'];
      _hargaController.text = produk['harga'].toString();
      _stokController.text = produk['stok'].toString();
    } else {
      _namaProdukController.clear();
      _hargaController.clear();
      _stokController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: GoogleFonts.poppins(fontSize: 20)),
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
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Memisahkan kedua tombol
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: onConfirm,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(produk == null ? 'Tambah' : 'Simpan'),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kasir',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab1',
        onPressed: () => _showProdukDialog(
          title: 'Tambah Produk',
          onConfirm: () {
            if (_formKey.currentState!.validate()) {
              _addProdukToSupabase();
            }
          },
        ),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 10,
          childAspectRatio: 4,
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['nama_produk'] ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Harga: Rp ${item['harga']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'Stok: ${item['stok']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showProdukDialog(
                        title: 'Edit Produk',
                        produk: item,
                        onConfirm: () {
                          if (_formKey.currentState!.validate()) {
                            _updateProdukToSupabase(item['produk_id']);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteProdukFromSupabase(item['produk_id']),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
