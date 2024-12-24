class HistoryModel {
  final int? id;
  final int idBarang;
  final DateTime tanggal;
  final int stokLama;
  final int stokBaru;
  final int perubahanStok;
  final String jenisTransaksi;

  HistoryModel({
    this.id,
    required this.idBarang,
    required this.tanggal,
    required this.stokLama,
    required this.stokBaru,
    required this.perubahanStok,
    required this.jenisTransaksi,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'],
      idBarang: map['id_barang'],
      tanggal: DateTime.parse(map['tanggal']),
      stokLama: map['stok_lama'],
      stokBaru: map['stok_baru'],
      perubahanStok: map['perubahan_stok'],
      jenisTransaksi: map['jenis_transaksi'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_barang': idBarang,
      'tanggal': tanggal.toIso8601String(),
      'stok_lama': stokLama,
      'stok_baru': stokBaru,
      'perubahan_stok': perubahanStok,
      'jenis_transaksi': jenisTransaksi,
    };
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      idBarang: json['id_barang'],
      tanggal: DateTime.parse(json['tanggal']),
      stokLama: json['stok_lama'],
      stokBaru: json['stok_baru'],
      perubahanStok: json['perubahan_stok'],
      jenisTransaksi: json['jenis_transaksi'],
    );
  }
}
