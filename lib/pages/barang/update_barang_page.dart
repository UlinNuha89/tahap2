import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/components/styles.dart';

import '../../models/product_model.dart';
import '../../models/supplier_model.dart';

class UpdateBarangPage extends StatefulWidget {
  final ProductModel product;

  const UpdateBarangPage({required this.product, Key? key}) : super(key: key);

  @override
  _UpdateBarangPageState createState() => _UpdateBarangPageState();
}

class _UpdateBarangPageState extends State<UpdateBarangPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _imageController = TextEditingController();
  List<SupplierModel> _supplierList = [];
  int? _selectedSupplierId;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _namaController.text = widget.product.nama;
      _deskripsiController.text = widget.product.deskripsi;
      _hargaController.text = widget.product.harga.toString();
      _kategoriController.text = widget.product.kategori;
      _selectedSupplierId = widget.product.idSupplier;
      _imageController.text = widget.product.imagePath;
    }
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final response =
          await Supabase.instance.client.from('suppliers').select();
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

  Future<void> _updateProduct() async {
    final nama = _namaController.text;
    final deskripsi = _deskripsiController.text;
    final harga = int.tryParse(_hargaController.text) ?? 0;
    final kategori = _kategoriController.text;

    if (nama.isEmpty ||
        deskripsi.isEmpty ||
        kategori.isEmpty ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua data harus diisi!')),
      );
      return;
    }

    try {
      if (_selectedImage != null) {
        final relativePath = widget.product.imagePath.split('/').last;
        if (relativePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('inventory')
              .remove([relativePath]);
        }
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        await Supabase.instance.client.storage
            .from('inventory')
            .upload(fileName, _selectedImage!);
        final imageUrl = Supabase.instance.client.storage
            .from('inventory')
            .getPublicUrl(fileName);
        await Supabase.instance.client.from('products').update({
          'nama': nama,
          'deskripsi': deskripsi,
          'kategori': kategori,
          'harga': harga,
          'image_path': imageUrl,
          'id_supplier': _selectedSupplierId,
        }).eq('id', widget.product.id);
      } else {
        await Supabase.instance.client.from('products').update({
          'nama': nama,
          'deskripsi': deskripsi,
          'kategori': kategori,
          'harga': harga,
          'id_supplier': _selectedSupplierId,
        }).eq('id', widget.product.id);
      }
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
        title: Text('Update Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _selectedImage == null
                  ? Image.network(
                      _imageController.text,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.broken_image,
                            size: 200, color: Colors.grey);
                      },
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : Icon(Icons.camera_alt,
                              size: 50, color: Colors.grey),
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
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Harga wajib diisi' : null,
              ),
              TextFormField(
                controller: _kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Kategori wajib diisi'
                    : null,
              ),
              SizedBox(height: 20),
              if (_supplierList.isNotEmpty)
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProduct,
                style: buttonStyle,
                child:
                    const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
