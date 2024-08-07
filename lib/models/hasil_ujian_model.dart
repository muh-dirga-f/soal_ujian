class HasilUjian {
  final String idHasilUjian;
  final String idUjian;
  final String idSiswa;
  final String idAcakanSoal;
  final String nilai;
  final String sisaWaktu;
  final String status;

  HasilUjian({
    required this.idHasilUjian,
    required this.idUjian,
    required this.idSiswa,
    required this.idAcakanSoal,
    required this.nilai,
    required this.sisaWaktu,
    required this.status,
  });

  factory HasilUjian.fromJson(Map<String, dynamic> json) {
    return HasilUjian(
      idHasilUjian: json['id_hasil_ujian'].toString(),
      idUjian: json['id_ujian'].toString(),
      idSiswa: json['id_siswa'].toString(),
      idAcakanSoal: json['id_acakan_soal'].toString(),
      nilai: json['nilai'].toString(),
      sisaWaktu: json['sisa_waktu'].toString(),
      status: json['status'].toString(),
    );
  }
}

class HasilUjianResponse {
  final bool status;
  final String message;
  final List<HasilUjian> dataHasilUjian;
  final int total;

  HasilUjianResponse({
    required this.status,
    required this.message,
    required this.dataHasilUjian,
    required this.total,
  });

  factory HasilUjianResponse.fromJson(Map<String, dynamic> json) {
    var hasilUjianList = <HasilUjian>[];
    if (json['data'] != null && json['data']['data_hasil_ujian'] != null) {
      var decodedData = json['data']['data_hasil_ujian'];
      if (decodedData is List) {
        hasilUjianList =
            decodedData.map((e) => HasilUjian.fromJson(e)).toList();
      }
    }
    return HasilUjianResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      dataHasilUjian: hasilUjianList,
      total: json['total'] ?? 0,
    );
  }
}
