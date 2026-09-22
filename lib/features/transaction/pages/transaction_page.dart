import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // =========================
  // COLORS
  // =========================

  static const Color backgroundColor = Color(0xFFFFF5E6);
  static const Color primaryColor = Color(0xFF9A4E25);
  static const Color darkBrown = Color(0xFF4A2A1A);
  static const Color softBrown = Color(0xFF927663);
  static const Color lightBrown = Color(0xFFD5B99A);
  static const Color cardColor = Color(0xFFFFFBF5);

  final TransactionService _transactionService = TransactionService();

  bool _isLoading = true;
  String? _errorMessage;

  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // =========================================================
  // LOAD TRANSACTIONS
  // =========================================================

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _transactionService.getTransactions();

      print('DATA DARI SERVICE: $data');

      final transactions = data
          .map(
            (item) => TransactionModel.fromJson(item),
          )
          .toList();

      print('MODEL BERHASIL: $transactions');

      // =========================
      // HANYA BULAN BERJALAN
      // =========================

      final currentDate = DateTime.now();

      final filteredTransactions = transactions.where((transaction) {
        return transaction.tanggalTransaksi.year == currentDate.year &&
            transaction.tanggalTransaksi.month == currentDate.month;
      }).toList();

      // =========================
      // TRANSAKSI TERBARU DI ATAS
      // =========================

      filteredTransactions.sort(
        (a, b) => b.tanggalTransaksi.compareTo(
          a.tanggalTransaksi,
        ),
      );

      if (!mounted) return;

      setState(() {
        _transactions = filteredTransactions;
        _isLoading = false;
      });
    } catch (e) {
      print('ERROR TRANSAKSI: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} '
        '${monthNames[date.month - 1]} '
        '${date.year}';
  }

  // =========================================================
  // FORMAT RUPIAH
  // =========================================================

  String _formatRupiah(double amount) {
    final value = amount.toInt().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(value[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  // =========================================================
  // CURRENT MONTH
  // =========================================================

  String _currentMonthName() {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return monthNames[DateTime.now().month - 1];
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // =========================
            // BACKGROUND DECORATION
            // =========================

            Positioned(
              top: -50,
              right: -50,
              child: _buildCircle(
                size: 150,
                color: const Color(0xFFF4DFC8),
              ),
            ),

            Positioned(
              top: 230,
              left: -80,
              child: _buildCircle(
                size: 160,
                color: const Color(0xFFF7E7D2),
              ),
            ),

            // =========================
            // CONTENT
            // =========================

            Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTransactions,
                    color: primaryColor,
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(
      20,
      20,
      20,
      12,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Lihat semua transaksi kamu di sini',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: softBrown,
          ),
        ),
      ],
    ),
  );
}

  // =========================================================
  // CONTENT
  // =========================================================

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 130),
          _buildErrorState(),
        ],
      );
    }

    if (_transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),
          _buildEmptyState(),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        25,
      ),
      children: [
        _buildPeriodInfo(),

        const SizedBox(height: 18),

        ..._transactions.map(
          _buildTransactionCard,
        ),
      ],
    );
  }

  // =========================================================
  // PERIOD INFO
  // =========================================================

  Widget _buildPeriodInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: lightBrown.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF4E1D3),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaksi ${_currentMonthName()}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: darkBrown,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Periode 1 - akhir ${_currentMonthName()}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: softBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TRANSACTION CARD
  // =========================================================

  Widget _buildTransactionCard(TransactionModel transaction) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFBF5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFD5B99A).withValues(alpha: 0.45),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4A2A1A).withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================
        // HEADER TRANSAKSI
        // =========================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF9A4E25).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF9A4E25),
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaksi #${transaction.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A2A1A),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _formatDate(transaction.tanggalTransaksi),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF927663),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Selesai',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // =========================
        // DETAIL PRODUK
        // =========================
        ...transaction.detailTransaksis.map(
          (detail) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.namaProduk ?? 'Produk',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A2A1A),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${detail.jumlah} × ${_formatRupiah(detail.hargaSatuan)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF927663),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  _formatRupiah(detail.subtotal),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A2A1A),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Divider(
          height: 20,
          color: Color(0xFFD5B99A),
        ),

        // =========================
        // TOTAL
        // =========================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Transaksi',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF927663),
              ),
            ),

            Text(
              _formatRupiah(transaction.totalTransaksi),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9A4E25),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lightBrown.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: Color(0xFFF4E1D3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: primaryColor,
              size: 30,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Belum ada transaksi',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Belum ada transaksi untuk bulan ${_currentMonthName()}.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: softBrown,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERROR STATE
  // =========================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lightBrown.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: primaryColor,
            size: 45,
          ),

          const SizedBox(height: 12),

          Text(
            'Gagal mengambil transaksi',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: softBrown,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _loadTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DECORATIVE CIRCLE
  // =========================================================

  Widget _buildCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
