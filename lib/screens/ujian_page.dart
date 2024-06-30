import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/soal_model.dart'; // Import model yang baru kita buat

class UjianPage extends StatefulWidget {
  final String idUjian;

  const UjianPage({Key? key, required this.idUjian}) : super(key: key);

  @override
  _UjianPageState createState() => _UjianPageState();
}

class _UjianPageState extends State<UjianPage> {
  late Future<SoalResponse> soalResponse;
  Map<String, String> selectedAnswers = {};

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
    int skor = 0;
    soalResponse.then((response) {
      response.dataSoal.forEach((soal) {
        if (selectedAnswers[soal.idSoal] == soal.kunci) {
          skor++;
        }
      });
      _showSkorDialog(skor);
    });
  }

  void _showSkorDialog(int skor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Skor Anda'),
          content: Text('Anda mendapatkan skor: $skor'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: soalList.length,
                      itemBuilder: (context, index) {
                        final soal = soalList[index];
                        return SoalItem(
                          nomor: index + 1,
                          soal: soal,
                          selectedAnswer: selectedAnswers[soal.idSoal],
                          onSelected: (String value) {
                            setState(() {
                              selectedAnswers[soal.idSoal] = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _simpanJawaban,
                      child: Text('Simpan Jawaban'),
                    ),
                  ),
                ],
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
    Key? key,
    required this.nomor,
    required this.soal,
    required this.selectedAnswer,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal $nomor: ${soal.soal}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  soal.mapel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
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
            Text(
              'Kunci: ${soal.kunci}',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
