import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/models/supplier_model.dart';
import '../../components/styles.dart';
import '../../models/product_model.dart';

class AddBarangPage extends StatefulWidget {
  @override
  _AddBarangPageState createState() => _AddBarangPageState();
}

class _AddBarangPageState extends State<AddBarangPage> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _kategoriController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  List<SupplierModel> _supplierList = [];
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }
  Future<void> _fetchSuppliers() async {
    try {
      final response = await Supabase.instance.client
          .from('suppliers')
          .select();
      setState(() {
        _supplierList = (response as List<dynamic>)
            .map((supplier) => SupplierModel.fromJson(supplier))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data supplier: $e')),
      );
    }
  }
  Future<void> _pickGalleryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCameraImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    final nama = _namaController.text;
    final deskripsi = _deskripsiController.text;
    final harga = int.tryParse(_hargaController.text) ?? 0;
    final stok = int.tryParse(_stokController.text) ?? 0;
    final kategori = _kategoriController.text;

    if (nama.isEmpty ||
        deskripsi.isEmpty ||
        kategori.isEmpty ||
        _selectedImage == null ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data harus diisi!')),
      );
      return;
    }

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      await Supabase.instance.client.storage
          .from('inventory')
          .upload(fileName, _selectedImage!);

      final imageUrl = Supabase.instance.client.storage
          .from('inventory')
          .getPublicUrl(fileName);

      await Supabase.instance.client.from('products').insert({
        'nama': nama,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'harga': harga,
        'stok': stok,
        'image_path': imageUrl,
        'id_supplier' : _selectedSupplierId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan!')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data Inventory'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text('Silahkan Isi Data Barang Baru',
                  style: headerStyle(level: 2)),
              SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickCameraImage,
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.camera, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Kamera',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickGalleryImage,
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Galeri',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _namaController,
                decoration: boxInputDecoration("Nama"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _deskripsiController,
                decoration: boxInputDecoration("Deskripsi"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: boxInputDecoration("Harga"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: boxInputDecoration("Stok"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _kategoriController,
                decoration: boxInputDecoration("Kategori"),
              ),
              SizedBox(height: 20),
              DropdownButton<int>(
                isExpanded: true,
                value: _selectedSupplierId,
                hint: Text('Pilih Supplier'),
                items: _supplierList.map((supplier) {
                  return DropdownMenuItem<int>(
                    value: supplier.id,
                    child: Text(supplier.nama),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _saveData,
                    style: buttonStyle,
                    child: Text(
                      'Simpan',
                      style: headerStyle(level: 4, dark: false),
                    )),
              ),
              SizedBox(height: 50)
            ],
          ),
        ),
      ),
    );
  }
}
