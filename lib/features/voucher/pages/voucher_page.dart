import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/voucher_model.dart';
import '../services/voucher_service.dart';

class VoucherPage extends StatefulWidget {
  final bool isActive;

  const VoucherPage({
    super.key,
    required this.isActive,
  });

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage>
    with SingleTickerProviderStateMixin {
  final VoucherService _voucherService = VoucherService();

  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  // =========================
  // COLORS - SAMA DENGAN HOME
  // =========================
  static const Color backgroundColor = Color(0xFFFFF5E6);
  static const Color primaryColor = Color(0xFF9A4E25);
  static const Color darkBrown = Color(0xFF4A2A1A);
  static const Color softBrown = Color(0xFF927663);
  static const Color lightBrown = Color(0xFFD5B99A);
  static const Color cardColor = Color(0xFFFFFBF5);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    _loadVouchers();
  }

  @override
  void didUpdateWidget(covariant VoucherPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _loadVouchers();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vouchers = await _voucherService.getVouchers();

      if (!mounted) return;

      setState(() {
        _vouchers = vouchers;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<VoucherModel> get _availableVouchers {
    return _vouchers.where((voucher) {
      return voucher.status == 'aktif' &&
          voucher.tanggalKadaluarsa.isAfter(DateTime.now());
    }).toList();
  }

  List<VoucherModel> get _usedVouchers {
    return _vouchers.where((voucher) {
      return voucher.status == 'terpakai';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // =========================
          // DEKORASI BACKGROUND
          // =========================
          Positioned(
            top: -65,
            right: -55,
            child: _buildCircle(
              size: 175,
              color: const Color(0xFFF4DFC8),
            ),
          ),

          Positioned(
            top: 235,
            left: -105,
            child: _buildCircle(
              size: 185,
              color: const Color(0xFFF7E7D2),
            ),
          ),

          Positioned(
            bottom: 80,
            right: -80,
            child: _buildCircle(
              size: 145,
              color: const Color(0xFFF9EBD9),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),

                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Voucher',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simpan dan gunakan voucher reward kamu',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: softBrown,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TAB BAR
  // =========================
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lightBrown.withValues(alpha: 0.7),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: softBrown,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Bisa Dipakai'),
          Tab(text: 'Terpakai'),
        ],
      ),
    );
  }

  // =========================
  // BODY
  // =========================
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: primaryColor,
              ),

              const SizedBox(height: 12),

              const Text(
                'Gagal memuat voucher',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: softBrown,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: _loadVouchers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildVoucherList(_availableVouchers),
        _buildVoucherList(_usedVouchers),
      ],
    );
  }

  // =========================
  // VOUCHER LIST
  // =========================
  Widget _buildVoucherList(List<VoucherModel> vouchers) {
    if (vouchers.isEmpty) {
      return RefreshIndicator(
        color: primaryColor,
        onRefresh: _loadVouchers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          children: [
            const SizedBox(height: 80),

            Icon(
              Icons.confirmation_number_outlined,
              size: 62,
              color: lightBrown,
            ),

            const SizedBox(height: 16),

            const Text(
              'Belum ada voucher',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkBrown,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Voucher dari hasil spin kamu akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: softBrown,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadVouchers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          return _buildVoucherCard(vouchers[index]);
        },
      ),
    );
  }

  // =========================
  // VOUCHER CARD
  // =========================
  Widget _buildVoucherCard(VoucherModel voucher) {
    final bool isUsed = voucher.status == 'terpakai';

    final String rewardText =
        voucher.jenisReward?.isNotEmpty == true
            ? voucher.jenisReward!
            : 'Voucher Reward';

    final String expiryText =
        '${voucher.tanggalKadaluarsa.day.toString().padLeft(2, '0')}/'
        '${voucher.tanggalKadaluarsa.month.toString().padLeft(2, '0')}/'
        '${voucher.tanggalKadaluarsa.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lightBrown.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // =========================
          // BAGIAN ATAS
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_rounded,
                    color: primaryColor,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VOUCHER REWARD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: softBrown,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        rewardText,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isUsed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: lightBrown.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Terpakai',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: softBrown,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // =========================
          // PEMISAH
          // =========================
          Row(
            children: [
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),

              Expanded(
                child: CustomPaint(
                  painter: _DashedLinePainter(
                    color: lightBrown.withValues(alpha: 0.8),
                  ),
                  child: const SizedBox(height: 1),
                ),
              ),

              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          // =========================
          // DETAIL VOUCHER
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      size: 18,
                      color: softBrown,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Kode Voucher',
                      style: TextStyle(
                        fontSize: 12,
                        color: softBrown,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      voucher.kodeVoucher,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: softBrown,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Berlaku sampai',
                      style: TextStyle(
                        fontSize: 12,
                        color: softBrown,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      expiryText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                  ],
                ),

                if (!isUsed) ...[
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        _showUseVoucherDialog(voucher);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'Gunakan Voucher',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // USE VOUCHER DIALOG
  // =========================
  void _showUseVoucherDialog(VoucherModel voucher) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Gunakan Voucher',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: darkBrown,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tunjukkan kode voucher ini kepada admin untuk digunakan.',
                style: TextStyle(
                  color: softBrown,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: lightBrown,
                  ),
                ),
                child: Text(
                  voucher.kodeVoucher,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: softBrown,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =========================
// DASHED LINE PAINTER
// =========================
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 6.0;
    const dashSpace = 5.0;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(
          (startX + dashWidth).clamp(0, size.width),
          0,
        ),
        paint,
      );

      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}