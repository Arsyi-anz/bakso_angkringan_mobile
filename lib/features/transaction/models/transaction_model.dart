class TransactionModel {
  final int id;
  final int customerId;
  final int? adminId;
  final double totalTransaksi;
  final DateTime tanggalTransaksi;
  final List<TransactionDetailModel> detailTransaksis;

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.adminId,
    required this.totalTransaksi,
    required this.tanggalTransaksi,
    required this.detailTransaksis,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final details = json['detail_transaksis'];

    return TransactionModel(
      id: (json['id'] as num).toInt(),

      customerId: (json['customer_id'] as num).toInt(),

      adminId: json['admin_id'] == null
          ? null
          : (json['admin_id'] as num).toInt(),

      totalTransaksi:
          double.tryParse(
                json['total_transaksi'].toString(),
              ) ??
              0.0,

      tanggalTransaksi: DateTime.parse(
        json['tanggal_transaksi'].toString(),
      ),

      detailTransaksis: details is List
          ? details
              .map(
                (item) => TransactionDetailModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }
}

class TransactionDetailModel {
  final int id;
  final int produkId;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final String? namaProduk;

  TransactionDetailModel({
    required this.id,
    required this.produkId,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    required this.namaProduk,
  });

  factory TransactionDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final produk = json['produk'];

    return TransactionDetailModel(
      id: (json['id'] as num).toInt(),

      produkId: json['produk_id'] == null
          ? (produk is Map
              ? (produk['id'] as num?)?.toInt() ?? 0
              : 0)
          : (json['produk_id'] as num).toInt(),

      jumlah: (json['jumlah'] as num).toInt(),

      hargaSatuan:
          double.tryParse(
                json['harga_satuan'].toString(),
              ) ??
              0.0,

      subtotal:
          double.tryParse(
                json['subtotal'].toString(),
              ) ??
              0.0,

      namaProduk: produk is Map
          ? produk['nama_produk']?.toString()
          : null,
    );
  }
}