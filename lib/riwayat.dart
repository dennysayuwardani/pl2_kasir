import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatPembelianPage extends StatefulWidget {
  const RiwayatPembelianPage({Key? key}) : super(key: key);

  @override
  _RiwayatPembelianPageState createState() => _RiwayatPembelianPageState();
}

class _RiwayatPembelianPageState extends State<RiwayatPembelianPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('penjualan')
            .stream(primaryKey: ['penjualan_id']) // Mendengarkan perubahan realtime
            .order('tanggal_penjualan', ascending: false)
            .map((data) => data.map((e) => e as Map<String, dynamic>).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada riwayat pembelian.'));
          }

          final riwayatPenjualan = snapshot.data!;

          return ListView.builder(
            itemCount: riwayatPenjualan.length,
            itemBuilder: (context, index) {
              final penjualan = riwayatPenjualan[index];

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: supabase
                    .from('detail_penjualan')
                    .select('produk_id, jumlah_produk, subtotal, produk(nama_produk)')
                    .eq('penjualan_id', penjualan['penjualan_id'])
                    .then((data) => data.map((e) => e as Map<String, dynamic>).toList()),
                builder: (context, detailSnapshot) {
                  if (detailSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (detailSnapshot.hasError) {
                    return Center(
                      child: Text('Gagal memuat detail: ${detailSnapshot.error}'),
                    );
                  }

                  final detailPenjualan = detailSnapshot.data ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID Penjualan: ${penjualan['penjualan_id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Tanggal: ${penjualan['tanggal_penjualan']}'),
                          Text('Total Harga: Rp ${penjualan['total_harga']}'),
                          const SizedBox(height: 8),
                          const Text(
                            'Detail Produk:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...detailPenjualan.map((detail) {
                            final namaProduk = detail['produk']?['nama_produk'] ?? 'Produk Tidak Ditemukan';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '- $namaProduk, Jumlah: ${detail['jumlah_produk']}, Subtotal: Rp ${detail['subtotal']}',
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus riwayat ini?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                try {
                                  await supabase
                                      .from('penjualan')
                                      .delete()
                                      .eq('penjualan_id', penjualan['penjualan_id']);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Riwayat penjualan berhasil dihapus')),
                                  );
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal menghapus riwayat: $error')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Hapus Riwayat'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
