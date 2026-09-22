class VoucherModel {
  final int id;
  final String kodeVoucher;
  final String? keterangan;
  final String status;
  final DateTime tanggalKadaluarsa;
  final String? jenisReward;

  VoucherModel({
    required this.id,
    required this.kodeVoucher,
    required this.keterangan,
    required this.status,
    required this.tanggalKadaluarsa,
    required this.jenisReward,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    final reward = json['reward'];

    return VoucherModel(
      id: (json['id'] as num).toInt(),
      kodeVoucher: json['kode_voucher']?.toString() ?? '',
      keterangan: json['keterangan']?.toString(),
      status: json['status']?.toString() ?? 'aktif',
      tanggalKadaluarsa: DateTime.parse(
        json['tanggal_kadaluarsa'].toString(),
      ),
      jenisReward: reward is Map
          ? reward['jenis_reward']?.toString()
          : null,
    );
  }
}