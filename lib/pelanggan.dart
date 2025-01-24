import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';


class PelangganScreen extends StatefulWidget {
  const PelangganScreen({Key? key}) : super(key: key);

  @override
  State<PelangganScreen> createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelanggan = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nomorTeleponController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
  }

  Future<void> _fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      _showError('Terjadi kesalahan saat mengambil data pelanggan: $e');
    }
  }

  Future<void> _addPelanggan() async {
    final String nama = _namaController.text;
    final String alamat = _alamatController.text;
    final String nomorTelepon = _nomorTeleponController.text;

    try {
      final response = await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.add(response.first);
        });
      }
      _showMessage('Pelanggan berhasil ditambahkan');
      Navigator.pop(context);
    } catch (e) {
      _showError('Gagal menambahkan pelanggan: $e');
    }
  }

  Future<void> _editPelanggan(int id) async {
    final String nama = _namaController.text;
    final String alamat = _alamatController.text;
    final String nomorTelepon = _nomorTeleponController.text;

    try {
      final response = await supabase
          .from('pelanggan')
          .update({
            'nama_pelanggan': nama,
            'alamat': alamat,
            'nomor_telepon': nomorTelepon,
          })
          .eq('pelanggan_id', id)
          .select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          final index =
              pelanggan.indexWhere((item) => item['pelanggan_id'] == id);
          if (index != -1) {
            pelanggan[index] = response.first;
          }
        });
      }
      _showMessage('Pelanggan berhasil diperbarui');
      Navigator.pop(context);
    } catch (e) {
      _showError('Gagal mengedit pelanggan: $e');
    }
  }

  Future<void> _deletePelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
      setState(() {
        pelanggan.removeWhere((item) => item['pelanggan_id'] == id);
      });
      _showMessage('Pelanggan berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus pelanggan: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showError(String message) {
    _showMessage(message);
  }

  void _showPelangganDialog({Map<String, dynamic>? pelangganData}) {
    if (pelangganData != null) {
      _namaController.text = pelangganData['nama_pelanggan'];
      _alamatController.text = pelangganData['alamat'];
      _nomorTeleponController.text = pelangganData['nomor_telepon'];
    } else {
      _namaController.clear();
      _alamatController.clear();
      _nomorTeleponController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              pelangganData == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                  controller: _namaController,
                  label: 'Nama Pelanggan',
                  validator: (value) =>
                      value!.isEmpty ? 'Nama pelanggan tidak boleh kosong' : null,
                ),
                _buildInputField(
                  controller: _alamatController,
                  label: 'Alamat',
                  validator: (value) =>
                      value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                ),
                _buildInputField(
                  controller: _nomorTeleponController,
                  label: 'Nomor Telepon',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) return 'Nomor telepon tidak boleh kosong';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Nomor telepon hanya boleh berisi angka';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            Row(
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
                      if (pelangganData == null) {
                        _addPelanggan();
                      } else {
                        _editPelanggan(pelangganData['pelanggan_id']);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Simpan'),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pelanggan.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada pelanggan!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pelanggan.length,
                  itemBuilder: (context, index) {
                    final item = pelanggan[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(
                          item['nama_pelanggan'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat: ${item['alamat']}'),
                            Text('Nomor Telepon: ${item['nomor_telepon']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showPelangganDialog(pelangganData: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deletePelanggan(item['pelanggan_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab2',
        onPressed: () => _showPelangganDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
