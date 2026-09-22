class RewardModel {
  final String periode;
  final bool layak;
  final int jumlahTransaksiBulan;
  final double totalTransaksiBulan;
  final int jumlahReferralBulan;
  final int syaratTransaksi;
  final int syaratReferral;
  final String pesan;

  RewardModel({
    required this.periode,
    required this.layak,
    required this.jumlahTransaksiBulan,
    required this.totalTransaksiBulan,
    required this.jumlahReferralBulan,
    required this.syaratTransaksi,
    required this.syaratReferral,
    required this.pesan,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      periode: json['periode']?.toString() ?? '',

      layak: json['layak'] == true,

      jumlahTransaksiBulan:
          (json['jumlah_transaksi_bulan'] as num?)?.toInt() ?? 0,

      totalTransaksiBulan:
          double.tryParse(
                json['total_transaksi_bulan'].toString(),
              ) ??
              0.0,

      jumlahReferralBulan:
          (json['jumlah_referral_bulan'] as num?)?.toInt() ?? 0,

      syaratTransaksi:
          (json['syarat_transaksi'] as num?)?.toInt() ?? 8,

      syaratReferral:
          (json['syarat_referral'] as num?)?.toInt() ?? 3,

      pesan: json['pesan']?.toString() ?? '',
    );
  }
}