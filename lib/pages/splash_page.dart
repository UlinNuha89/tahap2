import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashFull();
  }
}

class SplashFull extends StatefulWidget {
  const SplashFull({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashFull> {
  @override
  void initState() {
    super.initState();
    super.initState();
    _refreshSessionAndCheckLoginStatus();
  }

  Future<void> _refreshSessionAndCheckLoginStatus() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
      final session = Supabase.instance.client.auth.currentSession;
      Future.delayed(const Duration(seconds: 1), () {
        if (session != null) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: Scaffold(
      body: Center(
        child: Text('Selamat datang di Aplikasi Inventory',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    ));
  }
}
