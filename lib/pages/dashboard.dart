import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/components/styles.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<int> _getTotalProduct() async {
    try {
      final response = await Supabase.instance.client.from('products').select();
      if (response == null || response.isEmpty) {
        return 0;
      }
      return response.length;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data: ${e.message}');
    }
  }
  Future<int> _getTotalSupplier() async {
    try {
      final response = await Supabase.instance.client.from('suppliers').select();
      if (response == null || response.isEmpty) {
        return 0;
      }
      return response.length;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil data:\n ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FutureBuilder<int>(
                    future: _getTotalProduct(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final totalProduct = snapshot.data ?? 0;
                      return _DashboardCard(
                        title: 'Barang',
                        icon: Icons.inventory_sharp,
                        total: totalProduct,
                        onTap: () {
                          Navigator.pushNamed(context, '/barangList');
                        },
                      );
                    },
                  ),
                  FutureBuilder<int>(
                    future: _getTotalSupplier(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final totalSupplier = snapshot.data ?? 0;
                      return _DashboardCard(
                        title: 'Supplier',
                        icon: Icons.store,
                        total: totalSupplier,
                        onTap: () {
                          Navigator.pushNamed(context, '/supplierList');
                        },
                      );
                    },
                  ),
                ],
              ),
              const Spacer(), // Spacer untuk mendorong tombol ke bawah
              ElevatedButton(
                onPressed: _logout,
                style: buttonStyle,
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ));
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int total;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.total,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$total items',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: buttonStyle,
              child: const Text(
                'Lihat List',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
