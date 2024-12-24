import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahap2/pages/barang/list_barang_page.dart';
import 'package:tahap2/pages/dashboard.dart';
import 'package:tahap2/pages/login_page.dart';
import 'package:tahap2/pages/register_page.dart';
import 'package:tahap2/pages/splash_page.dart';
import 'package:tahap2/pages/supplier/list_supplier_page.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://xzsvyfksbijushibvvqg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6c3Z5ZmtzYmlqdXNoaWJ2dnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ4ODEzNzQsImV4cCI6MjA1MDQ1NzM3NH0.hox6Mrke0EycmKOwCsBfmjy86ryciDJF_HezJxG6gPE',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Inventaris',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/barangList': (context) => const ListBarangPage(),
        '/supplierList': (context) => const ListSupplierPage(),
      },
    );
  }
}
