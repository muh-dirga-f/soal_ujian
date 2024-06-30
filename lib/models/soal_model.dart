class Soal {
  final String idSoal;
  final String mapel;
  final String soal;
  final String a;
  final String b;
  final String c;
  final String d;
  final String kunci;

  Soal({
    required this.idSoal,
    required this.mapel,
    required this.soal,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.kunci,
  });

  factory Soal.fromJson(Map<String, dynamic> json) {
    return Soal(
      idSoal: json['id_soal'],
      mapel: json['mapel'],
      soal: json['soal'],
      a: json['a'],
      b: json['b'],
      c: json['c'],
      d: json['d'],
      kunci: json['kunci'],
    );
  }
}

class SoalResponse {
  final bool status;
  final String message;
  final List<Soal> dataSoal;

  SoalResponse({
    required this.status,
    required this.message,
    required this.dataSoal,
  });

  factory SoalResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data_soal'] as List;
    List<Soal> soalList = list.map((i) => Soal.fromJson(i)).toList();

    return SoalResponse(
      status: json['status'],
      message: json['message'],
      dataSoal: soalList,
    );
  }
}
