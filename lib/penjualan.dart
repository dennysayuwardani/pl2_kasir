import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({Key? key}) : super(key: key);

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Dropdown values
  int? selectedPelangganId;
  int? selectedProdukId;
  List<Map<String, dynamic>> pelangganList = [];
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> produkTerpilih = [];
  List<Map<String, dynamic>> historyPenjualan = [];

  // Total harga
  double totalHarga = 0;

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
    _fetchProduk();
  }

  Future<void> _fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        pelangganList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Gagal mengambil data pelanggan: $e');
    }
  }

  Future<void> _fetchProduk() async {
    try {
      final response = await supabase.from('produk').select();
      setState(() {
        produkList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Gagal mengambil data produk: $e');
    }
  }

  void _addProdukToCart(Map<String, dynamic> produk) {
    final int jumlah = 1; // Default jumlah
    final double subtotal = jumlah * (produk['harga'] as double);
    setState(() {
      produkTerpilih.add({
        ...produk,
        'jumlah_produk': jumlah,
        'subtotal': subtotal,
      });
      totalHarga += subtotal;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPilihPelanggan() async {
    final response = await supabase
        .from('pelanggan')
        .select('pelanggan_id, nama_pelanggan')
        .eq('kartu_member', true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _savePenjualan() async {
    if (selectedPelangganId == null || produkTerpilih.isEmpty) {
      _showError('Pilih pelanggan dan minimal satu produk.');
      return;
    }

    try {
      // Insert penjualan
      final penjualanResponse = await supabase.from('penjualan').insert({
        'tanggal_penjualan': DateTime.now().toIso8601String(),
        'total_harga': totalHarga,
        'pelanggan_id': selectedPelangganId,
      }).select().single();

      final penjualanId = penjualanResponse['penjualan_id'];

      // Insert detail penjualan
      for (var produk in produkTerpilih) {
        await supabase.from('detail_penjualan').insert({
          'penjualan_id': penjualanId,
          'produk_id': produk['produk_id'],
          'jumlah_produk': produk['jumlah_produk'],
          'subtotal': produk['subtotal'],
        });

        // Update stok produk
        final int newStok = produk['stok'] - produk['jumlah_produk'];
        await supabase.from('produk').update({'stok': newStok}).eq('produk_id', produk['produk_id']);
      }

      // Reset state
      setState(() {
        historyPenjualan.add({
          'penjualan_id': penjualanId,
          'tanggal_penjualan': DateTime.now().toIso8601String(),
          'total_harga': totalHarga,
          'pelanggan': selectedPelangganId != null ? produkTerpilih : 'Non-member',
        });
        selectedPelangganId = null;
        produkTerpilih.clear();
        totalHarga = 0;
      });

      _showSuccess('Penjualan berhasil disimpan.');
    } catch (e) {
      _showError('Gagal menyimpan penjualan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: const TextStyle(color: Colors.green))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Penjualan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                )),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown pelanggan
FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchPilihPelanggan(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final pelangganList = snapshot.data!;
              return DropdownButton<int?>(
                hint: Text('Pilih Pelanggan (Opsional)'),
                value: selectedPelangganId,
                onChanged: (value) {
                  setState(() {
                    selectedPelangganId = value;
                  });
                },
                items: pelangganList.map((pelanggan) {
                  return DropdownMenuItem<int?>(
                    value: pelanggan['pelanggan_id'],
                    child: Text(pelanggan['nama_pelanggan']),
                  );
                }).toList(),
              );
            },
          ),            const SizedBox(height: 16),

            // Dropdown produk
            DropdownButtonFormField<int>(
              hint: const Text('Pilih Produk'),
              onChanged: (value) {
                final produk = produkList.firstWhere((p) => p['produk_id'] == value);
                _addProdukToCart(produk);
              },
              items: produkList.map((produk) {
                return DropdownMenuItem<int>(
                  value: produk['produk_id'],
                  child: Text('${produk['nama_produk']} - Rp ${produk['harga']}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Produk terpilih
            Expanded(
              child: ListView.builder(
                itemCount: produkTerpilih.length,
                itemBuilder: (context, index) {
                  final produk = produkTerpilih[index];
                  return ListTile(
                    title: Text(produk['nama_produk']),
                    subtitle: Text('Jumlah: ${produk['jumlah_produk']}, Subtotal: Rp ${produk['subtotal']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          totalHarga -= produk['subtotal'];
                          produkTerpilih.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Total harga
            Text('Total Harga: Rp $totalHarga', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Tombol simpan
            ElevatedButton(
              onPressed: _savePenjualan,
              child: const Text('Simpan Penjualan'),
            ),
          ],
        ),
      ),
    );
  }
}
