import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHP;

  final TextEditingController _password = TextEditingController();


  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email!,
        password: _password.text,
      );

      if (response.user != null) {
        await Supabase.instance.client.from('users').insert({
          'id_user': response.user!.id,
          'nama': nama,
          'email': email,
          'no_hp': noHP,
          'created_at': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi berhasil!')),
        );
        await Supabase.instance.client.auth.signOut();
        Navigator.pushNamed(context, '/login');
      }
    } catch (e) {
      print('Database Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini tidak boleh kosong';
    }
    return null;
  }

  String? passConfirmationValidator(String? value, TextEditingController password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password.text) {
      return 'Password tidak cocok';
    }
    return null;
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
              SizedBox(height: 80),
              Text('Register', style: headerStyle(level: 1)),
              Container(
                child: const Text(
                  'Create your profile to start your journey',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 50),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputLayout(
                        'Nama',
                        TextFormField(
                          onChanged: (value) => nama = value,
                          validator: notEmptyValidator,
                          decoration:
                          customInputDecoration("Nama Lengkap"),
                        ),
                      ),
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
                        'No. Handphone',
                        TextFormField(
                          onChanged: (value) => noHP = value,
                          validator: notEmptyValidator,
                          keyboardType: TextInputType.number,
                          decoration:
                          customInputDecoration("08123123213"),
                        ),
                      ),
                      InputLayout(
                        'Password',
                        TextFormField(
                          controller: _password,
                          validator: notEmptyValidator,
                          obscureText: true,
                          decoration: customInputDecoration(""),
                        ),
                      ),
                      InputLayout(
                        'Konfirmasi Password',
                        TextFormField(
                          validator: (value) =>
                              passConfirmationValidator(value, _password),
                          obscureText: true,
                          decoration: customInputDecoration(""),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        width: double.infinity,
                        child: FilledButton(
                          style: buttonStyle,
                          child: Text('Register',
                              style: headerStyle(level: 2)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _registerUser();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login di sini',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
