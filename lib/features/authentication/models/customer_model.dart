class CustomerModel {
  final int id;
  final String nama;
  final String noHp;
  final String kodeReferral;
  final String tanggalDaftar;

  CustomerModel({
    required this.id,
    required this.nama,
    required this.noHp,
    required this.kodeReferral,
    required this.tanggalDaftar,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      nama: json['nama'] ?? '',
      noHp: json['no_hp'] ?? '',
      kodeReferral: json['kode_referral'] ?? '',
      tanggalDaftar: json['tanggal_daftar'] ?? '',
    );
  }
}