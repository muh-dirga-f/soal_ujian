class SoalResponse {
  final List<Soal> dataSoal;
  final DataAcakSoal dataAcakSoal;

  SoalResponse({required this.dataSoal, required this.dataAcakSoal});

  factory SoalResponse.fromJson(Map<String, dynamic> json) {
    return SoalResponse(
      dataSoal: List<Soal>.from(json['data_soal'].map((x) => Soal.fromJson(x))),
      dataAcakSoal: DataAcakSoal.fromJson(json['data_acak_soal']),
    );
  }
}

class DataAcakSoal {
  final String idAcakSoal;

  DataAcakSoal({required this.idAcakSoal});

  factory DataAcakSoal.fromJson(Map<String, dynamic> json) {
    return DataAcakSoal(
      idAcakSoal: json['id_acak_soal'],
    );
  }
}

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
