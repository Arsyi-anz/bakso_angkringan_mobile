import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/reward_model.dart';
import '../services/reward_service.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  static const Color backgroundColor = Color(0xFFFFF5E6);
  static const Color primaryColor = Color(0xFF9A4E25);
  static const Color darkBrown = Color(0xFF4A2A1A);
  static const Color softBrown = Color(0xFF927663);
  static const Color lightBrown = Color(0xFFD5B99A);
  static const Color cardColor = Color(0xFFFFFBF5);

  final RewardService _rewardService = RewardService();

  RewardModel? _reward;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReward();
  }

  Future<void> _loadReward() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reward = await _rewardService.getHampersReward();

      if (!mounted) return;

      setState(() {
        _reward = reward;
        _isLoading = false;
      });
    } catch (e) {
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

  String _formatRupiah(double value) {
    final formatted = value
        .round()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );

    return 'Rp $formatted';
  }

  String _formatPeriode(String periode) {
    if (periode.isEmpty) return '';

    final parts = periode.split('-');

    if (parts.length != 2) {
      return periode;
    }

    const months = [
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

    final month = int.tryParse(parts[1]);

    if (month == null ||
        month < 1 ||
        month > 12) {
      return periode;
    }

    return '${months[month - 1]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
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

            Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _errorMessage != null
                          ? _buildError()
                          : _reward == null
                              ? _buildEmpty()
                              : RefreshIndicator(
                                  color: primaryColor,
                                  onRefresh: _loadReward,
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(
                                      parent:
                                          BouncingScrollPhysics(),
                                    ),
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                      20,
                                      8,
                                      20,
                                      30,
                                    ),
                                    child: _buildContent(),
                                  ),
                                ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            'Reward',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pantau kelayakan hampers bulanan kamu',
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

  Widget _buildContent() {
    final reward = _reward!;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildRewardStatusCard(reward),

        const SizedBox(height: 18),

        _buildProgressCard(
          icon: Icons.receipt_long_rounded,
          title: 'Transaksi Bulanan',
          current: reward.jumlahTransaksiBulan,
          target: reward.syaratTransaksi,
          subtitle:
              'Minimal ${reward.syaratTransaksi} transaksi dalam sebulan',
        ),

        const SizedBox(height: 12),

        _buildProgressCard(
          icon: Icons.people_alt_rounded,
          title: 'Referral Bulanan',
          current: reward.jumlahReferralBulan,
          target: reward.syaratReferral,
          subtitle:
              'Minimal ${reward.syaratReferral} referral valid dalam sebulan',
        ),

        const SizedBox(height: 12),

        _buildTotalTransactionCard(reward),

        const SizedBox(height: 20),

        _buildRequirementCard(reward),

        const SizedBox(height: 20),

        _buildPeriodInfo(reward),
      ],
    );
  }

  Widget _buildRewardStatusCard(
    RewardModel reward,
  ) {
    final isEligible = reward.layak;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isEligible
            ? const Color(0xFFF8E9D7)
            : cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isEligible
              ? const Color(0xFFD5A878)
              : lightBrown,
        ),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(
                alpha: 0.10,
              ),
            ),
            child: Icon(
              isEligible
                  ? Icons.card_giftcard_rounded
                  : Icons.card_giftcard_outlined,
              size: 32,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            isEligible
                ? 'Selamat! 🎉'
                : 'Hampers Bulanan',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isEligible
                ? 'Kamu layak mendapatkan hampers bulanan.'
                : 'Kamu belum layak mendapatkan hampers bulan ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: softBrown,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.55,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Text(
              reward.pesan,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color: darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required int current,
    required int target,
    required String subtitle,
  }) {
    final progress =
        target <= 0
            ? 0.0
            : (current / target)
                .clamp(0.0, 1.0);

    final isComplete = current >= target;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: lightBrown,
        ),
        boxShadow: [
          BoxShadow(
            color:
                darkBrown.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: softBrown,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$current / $target',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                  color: isComplete
                      ? primaryColor
                      : darkBrown,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFEEDFD0),
              valueColor:
                  const AlwaysStoppedAnimation(
                primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 7),

          Align(
            alignment:
                Alignment.centerRight,
            child: Text(
              isComplete
                  ? 'Target tercapai ✓'
                  : 'Masih kurang ${target - current}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    FontWeight.w600,
                color: isComplete
                    ? primaryColor
                    : softBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTransactionCard(
    RewardModel reward,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: lightBrown,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: primaryColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Total transaksi bulan ini',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: softBrown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatRupiah(
                    reward.totalTransaksiBulan,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(
    RewardModel reward,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: lightBrown,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Ketentuan Hampers',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
              color: darkBrown,
            ),
          ),

          const SizedBox(height: 14),

          _buildRequirementItem(
            icon: Icons.receipt_long_rounded,
            text:
                'Minimal ${reward.syaratTransaksi}x transaksi dalam sebulan',
          ),

          const SizedBox(height: 10),

          _buildRequirementItem(
            icon: Icons.people_alt_rounded,
            text:
                'Minimal ${reward.syaratReferral} referral valid dalam sebulan',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: primaryColor,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.4,
              color: softBrown,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodInfo(
    RewardModel reward,
  ) {
    return Center(
      child: Text(
        'Periode: ${_formatPeriode(reward.periode)}',
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: softBrown,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: primaryColor,
            ),
            const SizedBox(height: 14),
            Text(
              'Gagal memuat reward',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ??
                  'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: softBrown,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loadReward,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 11,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'Data reward belum tersedia.',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: softBrown,
        ),
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
}