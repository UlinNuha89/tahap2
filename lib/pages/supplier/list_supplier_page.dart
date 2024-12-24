import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/pages/supplier/add_supplier_page.dart';
import 'package:tahap2/pages/supplier/detail_supplier_page.dart';
import '../../components/styles.dart';
import '../../models/product_model.dart';
import '../../models/supplier_model.dart';

class ListSupplierPage extends StatefulWidget {
  const ListSupplierPage({super.key});

  @override
  _ListSupplierPageState createState() => _ListSupplierPageState();
}

class _ListSupplierPageState extends State<ListSupplierPage> {
  late Future<List<SupplierModel>> _supplier;

  @override
  void initState() {
    super.initState();
    _refreshSupplier();
  }

  void _refreshSupplier() {
    setState(() {
      _supplier = _getSuppliersFromSupabase();
    });
  }

  Future<List<SupplierModel>> _getSuppliersFromSupabase() async {
    try {
      final response =
      await Supabase.instance.client.from('suppliers').select();
      return response.map((json) => SupplierModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> _deleteSupplier(int supplierId) async {
    try {
      final products = await Supabase.instance.client
          .from('products')
          .select('id,image_path')
          .eq('id_supplier', supplierId);
      final productData = products as List;
      final productIds = (products as List).map((product) => product['id']).toList();
      if (productIds.isNotEmpty) {
        await Supabase.instance.client
            .from('histories')
            .delete()
            .inFilter('id_barang', productIds);
      }
      for (final product in productData) {
        final imagePath = product['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          final relativePath = imagePath.split('/').last;
          await Supabase.instance.client.storage
              .from('inventory')
              .remove([relativePath]);
        }
      }
      await Supabase.instance.client
          .from('products')
          .delete()
          .eq('id_supplier', supplierId);
      await Supabase.instance.client
          .from('suppliers')
          .delete()
          .eq('id', supplierId);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Supplier berhasil dihapus!')));
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus supplier: $e')));
    }
  }

  Future<void> _updateSupplier(SupplierModel supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSupplierPage(supplier: supplier),
      ),
    );
    if (result == true) {
      _refreshSupplier();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Supplier'),
      ),
      body: FutureBuilder<List<SupplierModel>>(
        future: _supplier,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data barang.'));
          }
          final suppliers = snapshot.data!;

          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    supplier.nama,
                    style: headerStyle(level: 3),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alamat: ${supplier.alamat}',
                          style: headerStyle(level: 4)),
                      Text('Kontak: ${supplier.kontak}',
                          style: headerStyle(level: 4)),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailSupplierPage(supplier: supplier),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _updateSupplier(
                                supplier), // Navigate to update page
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: Text('Hapus Supplier'),
                                  content: Text(
                                      'Apakah Anda yakin ingin menghapus supplier ini?\nSemua data barang dan history yang memiliki supplier sama akan terhapus'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirmDelete == true) {
                            _deleteSupplier(supplier.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSupplierPage()),
          );
          if (result == true) {
            _refreshSupplier();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
