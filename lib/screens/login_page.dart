import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'my_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<dynamic> _dataSiswa = [];

  @override
  void initState() {
    super.initState();
    _fetchDataSiswa();
  }

  Future<void> _fetchDataSiswa() async {
    final apiKey = dotenv.env['API_KEY'];
    final apiUrl = dotenv.env['API_URL'];
    final url = '${apiUrl!}/data_siswa/all';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Api-Key': apiKey!,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _dataSiswa = jsonResponse['data']['data_siswa'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final user = _dataSiswa.firstWhere(
      (siswa) => siswa['username'] == username && siswa['password'] == password,
      orElse: () => null,
    );

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('id_siswa', user['id_siswa']);
      await prefs.setString('username', username);
      await prefs.setString('fullname', user['fullname']);
      await prefs.setString('nis', user['nis']);
      await prefs.setString('jk', user['jk']);
      await prefs.setString('jurusan', user['jurusan']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      // Tampilkan pesan kesalahan jika login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal, silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _dataSiswa.isEmpty ? null : _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
