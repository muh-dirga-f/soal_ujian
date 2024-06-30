import 'dart:convert';

class Ujian {
  final String idUjian;
  final String judul;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  Ujian({
    required this.idUjian,
    required this.judul,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  factory Ujian.fromJson(Map<String, dynamic> json) {
    return Ujian(
      idUjian: json['id_ujian'],
      judul: json['judul'],
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai']),
    );
  }

  String? get id => null;
}

class UjianResponse {
  final bool status;
  final String message;
  final List<Ujian> dataUjian;

  UjianResponse({
    required this.status,
    required this.message,
    required this.dataUjian,
  });

  factory UjianResponse.fromJson(String source) {
    final json = jsonDecode(source);
    final dataUjian = (json['data']['data_ujian'] as List)
        .map((item) => Ujian.fromJson(item))
        .toList();
    return UjianResponse(
      status: json['status'],
      message: json['message'],
      dataUjian: dataUjian,
    );
  }
}
