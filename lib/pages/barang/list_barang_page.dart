import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/pages/barang/detail_barang_page.dart';
import '../../models/product_model.dart';
import '../../components/styles.dart';
import 'add_barang_page.dart';

class ListBarangPage extends StatefulWidget {
  const ListBarangPage({super.key});

  @override
  State<ListBarangPage> createState() => _ListBarangPageState();
}

class _ListBarangPageState extends State<ListBarangPage> {
  late Future<List<ProductModel>> _products;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _products = _getProductsFromSupabase();
    });
  }

  Future<List<ProductModel>> _getProductsFromSupabase() async {
    try {
      final response = await Supabase.instance.client.from('products').select();
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Barang'),
      ),
      body: FutureBuilder<List<ProductModel>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada data barang.'));
            }
            final products = snapshot.data!;

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: product.imagePath != null
                        ? Image.network(
                            product.imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                            },
                          )
                        : Icon(Icons.image, size: 50, color: Colors.grey),
                    title: Text(
                      product.nama,
                      style: headerStyle(level: 3),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${product.kategori}',
                            style: headerStyle(level: 4)),
                        Text('Harga: Rp${product.harga}',
                            style: headerStyle(level: 4)),
                        Text('Stok: ${product.stok}',
                            style: headerStyle(level: 4)),
                      ],
                    ),
                    onTap:() async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailBarangPage(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBarangPage()),
          );
          if (result == true) {
            _refreshProducts();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
