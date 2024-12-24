import 'package:flutter/material.dart';
import 'package:tahap2/models/supplier_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/styles.dart';

class DetailSupplierPage extends StatefulWidget {
  final SupplierModel supplier;

  const DetailSupplierPage({required this.supplier, Key? key})
      : super(key: key);

  @override
  _DetailSupplierPageState createState() => _DetailSupplierPageState();
}

class _DetailSupplierPageState extends State<DetailSupplierPage> {
  late SupplierModel _supplier;

  @override
  void initState() {
    super.initState();
    _supplier = widget.supplier;
  }

  Future<void> _openGoogleMaps() async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/place/${_supplier.latitude},${_supplier.longitude}');
    if (await launchUrl(googleMapsUrl)) {
      throw Exception('Tidak dapat memanggil : $googleMapsUrl');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Supplier'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama: ${_supplier.nama}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Alamat: ${_supplier.alamat}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Kontak: ${_supplier.kontak}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Latitude: ${_supplier.latitude}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Longitude: ${_supplier.longitude}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _openGoogleMaps(),
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Lihat Di Google Maps',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
