import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../models/soal_model.dart';
import 'package:soal_ujian/screens/my_home_page.dart';

class UjianPage extends StatefulWidget {
  final String idUjian;
  const UjianPage({super.key, required this.idUjian});

  @override
  _UjianPageState createState() => _UjianPageState();
}

class _UjianPageState extends State<UjianPage> {
  late Future<SoalResponse> soalResponse;
  Map<String, String> selectedAnswers = {};
  int currentIndex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    soalResponse = fetchSoalData();
  }

  Future<SoalResponse> fetchSoalData() async {
    try {
      final apiKey = dotenv.env['API_KEY'];
      final apiUrl = dotenv.env['API_URL'];
      final url =
          '${apiUrl!}/data_ujian/soal?X-Api-Key=${apiKey!}&id=${widget.idUjian}';

      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return SoalResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      rethrow;
    }
  }

  void _simpanJawaban() {
    if (_formKey.currentState!.validate()) {
      int skor = 0;
      soalResponse.then((response) {
        final totalSoal = response.dataSoal.length;
        for (var soal in response.dataSoal) {
          if (selectedAnswers[soal.idSoal] == soal.kunci) {
            skor++;
          }
        }
        final hasilSkor = (skor / totalSoal) * 100;
        _postHasilUjian(hasilSkor.toString(), response.dataAcakSoal.idAcakSoal);
      });
    }
  }

  Future<void> _postHasilUjian(String hasilSkor, String idAcakSoal) async {
    final apiKey = dotenv.env['API_KEY'];
    final apiUrl = dotenv.env['API_URL'];
    final prefs = await SharedPreferences.getInstance();
    final jawaban = selectedAnswers.entries
        .map((entry) => {'id_soal': entry.key, 'jawaban': entry.value})
        .toList();

    final url = '${apiUrl!}/data_hasil_ujian/add';

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers['X-Api-Key'] = apiKey!
      ..fields['id_ujian'] = widget.idUjian
      ..fields['id_siswa'] = prefs.getString('id_siswa')!
      ..fields['id_acakan_soal'] = idAcakSoal
      ..fields['nilai'] = hasilSkor
      ..fields['sisa_waktu'] = '0'
      ..fields['status'] = 'selesai'
      ..fields['jawaban'] = jsonEncode(jawaban);

    print('URL: $url');
    print('Headers: Content-Type: multipart/form-data, X-Api-Key: $apiKey');
    print('Fields: ${request.fields}');

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        _showSkorDialog(hasilSkor);
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}');
        print('Response body: $responseBody');
        throw Exception('Failed to submit data');
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }

  void _showSkorDialog(String hasilSkor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hasil Ujian'),
          content: Text('Nilai Ujian Anda: $hasilSkor'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          const MyHomePage()), // Ganti dengan halaman Home Anda
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ujian'),
      ),
      body: Center(
        child: FutureBuilder<SoalResponse>(
          future: soalResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final soalList = snapshot.data!.dataSoal;
              final soal = soalList[currentIndex];
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SoalItem(
                        nomor: currentIndex + 1,
                        soal: soal,
                        selectedAnswer: selectedAnswers[soal.idSoal],
                        onSelected: (String value) {
                          setState(() {
                            selectedAnswers[soal.idSoal] = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: currentIndex == soalList.length - 1
                          ? ElevatedButton(
                              onPressed: _simpanJawaban,
                              child: const Text('Simpan Jawaban'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  currentIndex++;
                                });
                              },
                              child: const Text('Soal Selanjutnya'),
                            ),
                    ),
                  ],
                ),
              );
            }
            return const Text('No data available');
          },
        ),
      ),
    );
  }
}

class SoalItem extends StatelessWidget {
  final int nomor;
  final Soal soal;
  final String? selectedAnswer;
  final Function(String) onSelected;

  const SoalItem({
    super.key,
    required this.nomor,
    required this.soal,
    required this.selectedAnswer,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  Text(
                    'Soal $nomor:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    soal.mapel,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              // Menggunakan HtmlWidget untuk render HTML dari soal
              HtmlWidget(
                soal.soal,
                textStyle: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text('A: ${soal.a}'),
                leading: Radio<String>(
                  value: 'a',
                  groupValue: selectedAnswer,
                  onChanged: (String? value) {
                    onSelected(value!);
                  },
                ),
                tileColor: selectedAnswer == 'a' ? Colors.blue[100] : null,
              ),
              ListTile(
                title: Text('B: ${soal.b}'),
                leading: Radio<String>(
                  value: 'b',
                  groupValue: selectedAnswer,
                  onChanged: (String? value) {
                    onSelected(value!);
                  },
                ),
                tileColor: selectedAnswer == 'b' ? Colors.blue[100] : null,
              ),
              ListTile(
                title: Text('C: ${soal.c}'),
                leading: Radio<String>(
                  value: 'c',
                  groupValue: selectedAnswer,
                  onChanged: (String? value) {
                    onSelected(value!);
                  },
                ),
                tileColor: selectedAnswer == 'c' ? Colors.blue[100] : null,
              ),
              ListTile(
                title: Text('D: ${soal.d}'),
                leading: Radio<String>(
                  value: 'd',
                  groupValue: selectedAnswer,
                  onChanged: (String? value) {
                    onSelected(value!);
                  },
                ),
                tileColor: selectedAnswer == 'd' ? Colors.blue[100] : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
