import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({Key? key}) : super(key: key);

  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  int? selectedPelangganId;
  List<Map<String, dynamic>> pelangganList = [];
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> produkTerpilih = [];
  double totalHarga = 0;

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
    _fetchProduk();
  }

  Future<void> _fetchPelanggan() async {
    final response = await supabase.from('pelanggan').select();
    if (mounted) {
      setState(() {
      pelangganList = List<Map<String, dynamic>>.from(response);
    });
    }
  }

  Future<void> _fetchProduk() async {
    final response = await supabase.from('produk').select();
    if (mounted) {
      setState(() {
      produkList = List<Map<String, dynamic>>.from(response);
    });
    }
  }

  void _addProdukToCart(Map<String, dynamic> produk) {
    final existingProduk = produkTerpilih.firstWhere(
        (item) => item['produk_id'] == produk['produk_id'], orElse: () => {});
    setState(() {
      if (existingProduk.isNotEmpty) {
        existingProduk['jumlah_produk']++;
        existingProduk['subtotal'] =
            existingProduk['jumlah_produk'] * produk['harga'];
      } else {
        produkTerpilih.add({
          ...produk,
          'jumlah_produk': 1,
          'subtotal': produk['harga'],
        });
      }
      totalHarga += produk['harga'];
    });
  }

  void _removeProdukFromCart(Map<String, dynamic> produk) {
    final existingProduk = produkTerpilih.firstWhere(
        (item) => item['produk_id'] == produk['produk_id'], orElse: () => {});
    if (existingProduk.isNotEmpty) {
      if (existingProduk['jumlah_produk'] > 1) {
        existingProduk['jumlah_produk']--;
        existingProduk['subtotal'] =
            existingProduk['jumlah_produk'] * produk['harga'];
        totalHarga -= produk['harga'];
      } else {
        produkTerpilih.remove(existingProduk);
        totalHarga -= produk['harga'];
      }
    }
  }

  void _goToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          pelangganId: selectedPelangganId,
          produkTerpilih: produkTerpilih,
          totalHarga: totalHarga,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Penjualan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int?>(
              hint: const Text('Pilih Pelanggan (Opsional)'),
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
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              hint: const Text('Pilih Produk'),
              onChanged: (value) {
                final produk =
                    produkList.firstWhere((p) => p['produk_id'] == value);
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
            Expanded(
              child: ListView.builder(
                itemCount: produkTerpilih.length,
                itemBuilder: (context, index) {
                  final produk = produkTerpilih[index];
                  return ListTile(
                    title: Text(produk['nama_produk']),
                    subtitle: Text('Subtotal: Rp ${produk['subtotal']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _removeProdukFromCart(produk),
                        ),
                        Text('${produk['jumlah_produk']}'),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addProdukToCart(produk),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text('Total Harga: Rp $totalHarga',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: produkTerpilih.isEmpty ? null : _goToCheckout,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  final int? pelangganId;
  final List<Map<String, dynamic>> produkTerpilih;
  final double totalHarga;

  const CheckoutScreen({
    Key? key,
    required this.pelangganId,
    required this.produkTerpilih,
    required this.totalHarga,
  }) : super(key: key);

  Future<void> _konfirmasiPembelian(BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;

      // Insert ke tabel penjualan
      final penjualanResponse = await supabase
          .from('penjualan')
          .insert({
            'tanggal_penjualan': DateTime.now().toIso8601String(),
            'total_harga': totalHarga,
            'pelanggan_id': pelangganId,
          })
          .select()
          .single();

      final penjualanId = penjualanResponse['penjualan_id'];

      // Insert ke tabel detail_penjualan
      for (var produk in produkTerpilih) {
        await supabase.from('detail_penjualan').insert({
          'penjualan_id': penjualanId,
          'produk_id': produk['produk_id'],
          'jumlah_produk': produk['jumlah_produk'],
          'subtotal': produk['subtotal'],
        });

        // Update stok produk
        final int newStok = produk['stok'] - produk['jumlah_produk'];
        await supabase
            .from('produk')
            .update({'stok': newStok}).eq('produk_id', produk['produk_id']);
      }

      // Notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembelian berhasil disimpan.'), backgroundColor: Colors.green),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // Notifikasi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pembelian: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pelanggan: ${pelangganId ?? "Non-member"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Produk yang dibeli:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: produkTerpilih.length,
                itemBuilder: (context, index) {
                  final produk = produkTerpilih[index];
                  return ListTile(
                    title: Text(produk['nama_produk']),
                    subtitle: Text('Jumlah: ${produk['jumlah_produk']}, Subtotal: Rp ${produk['subtotal']}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Total Harga: Rp $totalHarga', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _konfirmasiPembelian(context);
              },
              child: const Text('Konfirmasi Pembelian'),
            ),
          ],
        ),
      ),
    );
  }
}
