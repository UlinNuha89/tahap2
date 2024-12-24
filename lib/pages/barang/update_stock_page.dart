import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/styles.dart';
import '../../models/product_model.dart';

class UpdateStockPage extends StatefulWidget {
  final ProductModel product;

  const UpdateStockPage({required this.product, Key? key}) : super(key: key);

  @override
  _UpdateStockPageState createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  late ProductModel _product;
  final stockController = TextEditingController();
  String jenisTransaksi = "Masuk";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _updateAndAddHistory() async {
    final stokLama = _product.stok;
    final perubahanStok = int.tryParse(stockController.text);
    if (perubahanStok == null || perubahanStok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan jumlah stok yang valid!')),
      );
      return;
    } else if (jenisTransaksi == 'Keluar' && perubahanStok > _product.stok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stok keluar tidak bisa lebih dari stok yang ada')));
      return;
    }

    if (_product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID produk tidak valid!')),
      );
      return;
    }
    late int stokBaru;
    if (jenisTransaksi == "Masuk") {
      stokBaru = stokLama + perubahanStok;
    } else {
      stokBaru = stokLama - perubahanStok;
    }
    try {
      await Supabase.instance.client.from('histories').insert({
        'id_barang': _product.id,
        'tanggal': selectedDate.toIso8601String(),
        'stok_lama': stokLama,
        'stok_baru': stokBaru,
        'perubahan_stok': perubahanStok,
        'jenis_transaksi': jenisTransaksi,
      });
      await Supabase.instance.client.from('products').update({
        'stok': stokBaru,
      }).eq('id', _product.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok berhasil diperbarui.')),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Stok Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${_product.nama}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Harga: Rp${_product.harga}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Stok Sekarang: ${_product.stok}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Jenis Transaksi: '),
                DropdownButton<String>(
                  value: jenisTransaksi,
                  items: ['Masuk', 'Keluar'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      jenisTransaksi = newValue!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Stok Baru',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Pilih Tanggal: '),
                TextButton.icon(
                  onPressed: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    DateFormat('dd-MM-yyyy').format(selectedDate),
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateAndAddHistory,
              style: buttonStyle,
              child: Text(
                'Update Stok',
                style: textStyle(level: 4, dark: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
