import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? email;
  String? password;

  String? notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini tidak boleh kosong';
    }
    return null;
  }

 Future<void> _loginWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email!,
        password: password!,
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    }on AuthException catch (e) {
      String message = 'Terjadi kesalahan. Silakan coba lagi.';
      if (e.message.contains('Invalid login credentials')) {
        message = 'Email atau password salah.';
      } else if (e.message.contains('User not found')) {
        message = 'Pengguna tidak ditemukan.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    Text('Login', style: headerStyle(level: 1)),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        'Masuk ke akun Anda',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputLayout(
                              'Email',
                              TextFormField(
                                onChanged: (value) => email = value,
                                validator: notEmptyValidator,
                                decoration:
                                    customInputDecoration("email@email.com"),
                              ),
                            ),
                            InputLayout(
                              'Password',
                              TextFormField(
                                onChanged: (value) => password = value,
                                validator: notEmptyValidator,
                                obscureText: true,
                                decoration: customInputDecoration("******"),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: double.infinity,
                              child: FilledButton(
                                style: buttonStyle,
                                onPressed: _loginWithEmailPassword,//_loginWithEmailPassword,
                                child: Text('Login',
                                    style: headerStyle(level: 2, dark: false)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? '),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Daftar di sini',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
