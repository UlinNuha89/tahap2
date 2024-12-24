class ProductModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final int harga;
  final int stok;
  final String imagePath;
  final int idSupplier;

  ProductModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.imagePath,
    required this.idSupplier,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? 0,
      nama: map['nama'],
      deskripsi: map['deskripsi'],
      kategori: map['kategori'],
      harga: map['harga'],
      stok: map['stok'],
      imagePath: map['image_path'],
      idSupplier: map['id_supplier'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String,dynamic> {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'harga': harga,
      'stok': stok,
      'image_path': imagePath,
      'id_supplier': idSupplier,
    };
  }
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      harga: json['harga'],
      stok: json['stok'],
      imagePath: json['image_path'],
      idSupplier: json['id_supplier'],
    );
  }

}
