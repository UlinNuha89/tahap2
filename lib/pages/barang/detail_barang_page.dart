import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/pages/barang/update_barang_page.dart';
import 'package:tahap2/pages/barang/update_stock_page.dart';
import '../../components/styles.dart';
import '../../models/history_model.dart';
import '../../models/product_model.dart';

class DetailBarangPage extends StatefulWidget {
  final ProductModel product;

  const DetailBarangPage({required this.product, Key? key}) : super(key: key);

  @override
  _DetailBarangPageState createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  late Future<List<HistoryModel>> _History;
  late ProductModel _product;
  String? _supplierName;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _History = _getHistoriesFromSupabase();
    _fetchSupplierName();
  }

  Future<void> _fetchSupplierName() async {
    try {
      final response = await Supabase.instance.client
          .from('suppliers')
          .select('nama')
          .eq('id', _product.idSupplier)
          .single();
      setState(() {
        _supplierName = response['nama'] as String?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil nama supplier: $e')),
      );
    }
  }

  Future<ProductModel> _getProductFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('id', _product.id);
      return response.map((json) => ProductModel.fromJson(json)).toList().first;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil product: ${e.message}');
    }
  }

  Future<List<HistoryModel>> _getHistoriesFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('histories')
          .select()
          .eq('id_barang', _product.id);
      return (response as List)
          .map((json) => HistoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch histories: $e');
    }
  }

  Future<void> _refreshProduct() async {
    try {
      final results = await Future.wait([
        _getProductFromSupabase(),
        _getHistoriesFromSupabase(),
        _fetchSupplierName(),
      ]);
      setState(() {
        _product = results[0] as ProductModel;
        _History = Future.value(results[1] as List<HistoryModel>);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $e')),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final relativePath = _product.imagePath.split('/').last;
        if (relativePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('inventory')
              .remove([relativePath]);
        }
        await Future.wait([
          Supabase.instance.client
              .from('products')
              .delete()
              .eq('id', _product.id),
          Supabase.instance.client
              .from('histories')
              .delete()
              .eq('id_barang', _product.id),
        ]);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Barang dan histori berhasil dihapus.')));
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (Route<dynamic> route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus barang: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Barang'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _product.imagePath != null && _product.imagePath.isNotEmpty
                  ? Image.network(
                      _product.imagePath,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image,
                            size: 200, color: Colors.grey);
                      },
                    )
                  : Icon(Icons.image, size: 200, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                _product.nama,
                style: headerStyle(level: 2),
              ),
              SizedBox(height: 8),
              Text(
                'Supplier: ${_supplierName ?? 'Loading...'}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Kategori: ${_product.kategori}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Harga: Rp${_product.harga}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Stok: ${_product.stok}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Deskripsi:',
                style: textStyle(level: 2),
              ),
              SizedBox(height: 4),
              Text(
                _product.deskripsi,
                style: textStyle(level: 4),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _deleteProduct(context),
                    style: buttonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(dangerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Hapus',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateStockPage(product: _product),
                        ),
                      );
                      if (result == true) {
                        await _refreshProduct();
                      }
                    },
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Update Stok',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateBarangPage(product: _product),
                          ));
                    },
                    style: buttonStyle ,
                    child: Row(
                      children: [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Update Barang',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ]
              ),
              SizedBox(height: 20),
              FutureBuilder<List<HistoryModel>>(
                future: _History,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada data histori.'));
                  }

                  final histories = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return Card(
                        key: Key(history.id.toString()),
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal : ' +
                                    DateFormat('dd-MM-yyyy')
                                        .format(history.tanggal),
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Jenis Transaksi: ${history.jenisTransaksi}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Stok Lama: ${history.stokLama}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Stok Baru: ${history.stokBaru}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Perubahan Stok: ${history.perubahanStok}',
                                style: headerStyle(level: 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
