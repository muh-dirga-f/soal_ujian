import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soal_ujian/models/hasil_ujian_model.dart';
import 'package:soal_ujian/models/ujian_model.dart';
import 'ujian_page.dart';
import 'profile_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<UjianResponse> ujianResponse;
  late Future<HasilUjianResponse> hasilUjianResponse;
  Timer? _timer;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    ujianResponse = fetchUjianData();
    hasilUjianResponse = fetchHasilUjianData();
  }

  Future<UjianResponse> fetchUjianData() async {
    final apiKey = dotenv.env['API_KEY'];
    final apiUrl = dotenv.env['API_URL'];
    final url = '${apiUrl!}/data_ujian/all';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Api-Key': apiKey!,
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return UjianResponse.fromJson(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<HasilUjianResponse> fetchHasilUjianData() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = dotenv.env['API_KEY'];
    final apiUrl = dotenv.env['API_URL'];
    final idSiswa = prefs.getString('id_siswa');

    // Get the idUjian from the available ujian or set to 0 if no ujian is available
    UjianResponse ujianResponse = await fetchUjianData();
    final idUjian = ujianResponse.dataUjian.isNotEmpty
        ? ujianResponse.dataUjian.first.idUjian
        : '0';

    final url =
        '$apiUrl/data_hasil_ujian/all?X-Api-Key=$apiKey&filter=&field=&start=&limit=&filters[0][co][0][fl]=id_ujian&filters[0][co][0][op]=equal&filters[0][co][0][vl]=$idUjian&filters[0][co][0][lg]=and&filters[0][co][1][fl]=id_siswa&filters[0][co][1][op]=equal&filters[0][co][1][vl]=$idSiswa&filters[0][co][1][lg]=and&sort_field=&sort_order=ASC';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print(response.body);
      return HasilUjianResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  void startTimer(DateTime ujianStartTime) {
    final now = DateTime.now();
    final initialDuration = ujianStartTime.difference(now);
    if (_timer != null) {
      _timer!.cancel();
    }
    _duration = initialDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        final secondsRemaining = _duration!.inSeconds - 1;
        if (secondsRemaining > 0) {
          _duration = Duration(seconds: secondsRemaining);
        } else {
          _timer!.cancel();
          _duration = const Duration(seconds: 0);
        }
      });
    });
  }

  void navigateToUjianPage(BuildContext context, idUjian) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UjianPage(idUjian: idUjian),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ujian"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<HasilUjianResponse>(
          future: hasilUjianResponse,
          builder: (context, hasilSnapshot) {
            if (hasilSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (hasilSnapshot.hasError) {
              return Text("Error: ${hasilSnapshot.error}");
            } else if (hasilSnapshot.hasData) {
              final hasUjianCompleted =
                  hasilSnapshot.data!.dataHasilUjian.isNotEmpty;
              return FutureBuilder<UjianResponse>(
                future: ujianResponse,
                builder: (context, ujianSnapshot) {
                  if (ujianSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (ujianSnapshot.hasError) {
                    return Text("Error: ${ujianSnapshot.error}");
                  } else if (ujianSnapshot.hasData) {
                    final ujian = ujianSnapshot.data!.dataUjian.isNotEmpty
                        ? ujianSnapshot.data!.dataUjian.first
                        : null;
                    if (ujian == null) {
                      return const Text("Belum ada ujian");
                    }

                    if (hasUjianCompleted) {
                      return const Text("Ujian telah selesai");
                    }

                    final now = DateTime.now();
                    if (now.isAfter(ujian.tanggalMulai) &&
                        now.isBefore(ujian.tanggalSelesai)) {
                      return ElevatedButton(
                        onPressed: () {
                          navigateToUjianPage(context, ujian.idUjian);
                        },
                        child: const Text("Mulai Ujian"),
                      );
                    } else if (ujian.tanggalMulai.isAfter(now) &&
                        ujian.tanggalMulai.day == now.day) {
                      if (_timer == null) {
                        startTimer(ujian.tanggalMulai);
                      }
                      if (_duration != null && _duration!.inSeconds > 0) {
                        final hours = _duration!.inHours;
                        final minutes = _duration!.inMinutes % 60;
                        final seconds = _duration!.inSeconds % 60;
                        return Text(
                            "Ujian dimulai dalam $hours jam $minutes menit $seconds detik");
                      } else {
                        return ElevatedButton(
                          onPressed: () {
                            navigateToUjianPage(context, ujian.idUjian);
                          },
                          child: const Text("Mulai Ujian"),
                        );
                      }
                    } else {
                      return const Text("Belum ada ujian");
                    }
                  }
                  return const Text("Belum ada ujian");
                },
              );
            }
            return const Text("Belum ada ujian");
          },
        ),
      ),
    );
  }
}
