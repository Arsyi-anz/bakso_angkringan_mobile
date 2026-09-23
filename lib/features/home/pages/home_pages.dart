import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../transaction/models/transaction_model.dart';
import '../../transaction/services/transaction_service.dart';
import '../../spin/services/spin_service.dart';
import '../../spin/services/instagram_story_service.dart';

class HomePage extends StatefulWidget {
  // =========================
  // DATA USER
  // =========================

  final String userName;
  final String noHp;
  final String kodeReferral;
  final Uint8List? profileImage;
  final VoidCallback onLihatSemuaTransaksi;

  const HomePage({
    super.key,
    required this.userName,
    required this.noHp,
    required this.kodeReferral,
    required this.profileImage,
    required this.onLihatSemuaTransaksi,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // =========================
  // COLORS
  // =========================

  static const Color backgroundColor = Color(0xFFFFF5E6);
  static const Color primaryColor = Color(0xFF9A4E25);
  static const Color darkBrown = Color(0xFF4A2A1A);
  static const Color softBrown = Color(0xFF927663);
  static const Color lightBrown = Color(0xFFD5B99A);
  static const Color cardColor = Color(0xFFFFFBF5);

  // =========================
  // SERVICES
  // =========================

  final TransactionService _transactionService =
      TransactionService();

  final SpinService _spinService = SpinService();

  final InstagramStoryService _instagramStoryService =
      InstagramStoryService();

  // =========================
  // TRANSACTION
  // =========================

  TransactionModel? _latestTransaction;

  bool _isLoadingTransaction = true;

  // =========================
  // SPIN
  // =========================

  int _spinChance = 0;
  int? _transaksiIdUntukSpin;
  int? _buktiIgStoryIdUntukSpin;

  bool _isLoadingSpin = true;

  // =========================
  // INSTAGRAM STORY
  // =========================

  final TextEditingController _instagramController =
      TextEditingController();

  bool _isSubmittingInstagram = false;
  String? _instagramStatus;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadLatestTransaction();
    _loadSpinStatus();
    _loadInstagramStoryStatus();
  }

  @override
  void dispose() {
    _instagramController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOAD LATEST TRANSACTION
  // =========================================================

  Future<void> _loadLatestTransaction() async {
    try {
      final data =
          await _transactionService.getTransactions();

      final transactions = data
          .map(
            (item) => TransactionModel.fromJson(item),
          )
          .toList();

      transactions.sort(
        (a, b) => b.tanggalTransaksi.compareTo(
          a.tanggalTransaksi,
        ),
      );

      if (!mounted) return;

      setState(() {
        _latestTransaction =
            transactions.isNotEmpty
                ? transactions.first
                : null;

        _isLoadingTransaction = false;
      });
    } catch (e) {
      print('ERROR HOME TRANSAKSI: $e');

      if (!mounted) return;

      setState(() {
        _latestTransaction = null;
        _isLoadingTransaction = false;
      });
    }
  }

  // =========================================================
  // LOAD SPIN STATUS
  // =========================================================

  Future<void> _loadSpinStatus() async {
    try {
      final data = await _spinService.getStatus();

      final transaksiBisaSpin =
          data['transaksi_bisa_spin'] is List
              ? List<dynamic>.from(
                  data['transaksi_bisa_spin'],
                )
              : [];

      final linkIgBisaClaim =
          data['link_ig_bisa_claim'] is List
              ? List<dynamic>.from(
                  data['link_ig_bisa_claim'],
                )
              : [];

      int? transaksiId;
      int? buktiIgStoryId;

      if (transaksiBisaSpin.isNotEmpty) {
        transaksiId =
            (transaksiBisaSpin.first['id'] as num).toInt();
      }

      if (linkIgBisaClaim.isNotEmpty) {
        buktiIgStoryId =
            (linkIgBisaClaim.first['id'] as num).toInt();
      }

      if (!mounted) return;

      setState(() {
        _spinChance =
            transaksiBisaSpin.length +
            linkIgBisaClaim.length;

        _transaksiIdUntukSpin = transaksiId;
        _buktiIgStoryIdUntukSpin = buktiIgStoryId;

        _isLoadingSpin = false;
      });
    } catch (e) {
      print('ERROR HOME SPIN: $e');

      if (!mounted) return;

      setState(() {
        _spinChance = 0;
        _transaksiIdUntukSpin = null;
        _buktiIgStoryIdUntukSpin = null;
        _isLoadingSpin = false;
      });
    }
  }

  // =========================================================
  // LOAD INSTAGRAM STORY STATUS
  // =========================================================

  Future<void> _loadInstagramStoryStatus() async {
  try {
    final stories =
        await _instagramStoryService.getMyStories();

    if (!mounted) return;

    if (stories.isEmpty) {
      setState(() {
        _instagramStatus = null;
      });
      return;
    }

    final latestStory = stories.first;

    final storyId =
        (latestStory['id'] as num?)?.toInt();

    final status =
        latestStory['status_verifikasi']?.toString();

    setState(() {
      _instagramStatus = status;
    });

    // =====================================================
    // IDENTITAS CUSTOMER
    // =====================================================

    final prefs =
        await SharedPreferences.getInstance();

    final customerId =
        prefs.getInt('customer_id');

    // Kalau customer ID belum tersedia,
    // jangan jalankan sistem notifikasi.
    if (customerId == null || storyId == null) {
      return;
    }

    // =====================================================
    // KEY KHUSUS CUSTOMER + STORY
    // =====================================================

    final lastSeenKey =
        'instagram_last_seen_story_${customerId}_$storyId';

    final lastSeenStatus =
        prefs.getString(lastSeenKey);

    // =====================================================
    // PERTAMA KALI MELIHAT STORY INI
    // =====================================================

    if (lastSeenStatus == null) {
      await prefs.setString(
        lastSeenKey,
        status ?? '',
      );
      return;
    }

    // =====================================================
    // STATUS BERUBAH MENJADI DITERIMA / DITOLAK
    // =====================================================

    if (status != null &&
        status != lastSeenStatus &&
        (status == 'diterima' ||
            status == 'ditolak')) {
      await prefs.setString(
        lastSeenKey,
        status,
      );

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _showInstagramStatusDialog(status);
      });
    }
  } catch (e) {
    print(
      'ERROR HOME INSTAGRAM STORY: $e',
    );
  }
}

  // =========================================================
  // SUBMIT INSTAGRAM STORY
  // =========================================================

  Future<void> _submitInstagramStory(String link) async {
    if (link.trim().isEmpty) {
      _showInstagramStatusDialog(
        'kosong',
      );
      return;
    }

    setState(() {
      _isSubmittingInstagram = true;
    });

    try {
      await _instagramStoryService.submitStory(
        link.trim(),
      );

      if (!mounted) return;

      setState(() {
        _instagramStatus = 'pending';
        _instagramController.clear();
      });

      // Simpan status terakhir yang sudah diketahui
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'instagram_last_seen_status',
        'pending',
      );

      if (!mounted) return;

      // Dialog setelah berhasil upload
      _showInstagramStatusDialog(
        'pending',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSubmittingInstagram = false;
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
      if (i > 0 &&
          (value.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(value[i]);
    }

    return 'Rp ${buffer.toString()}';
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

            // =========================
            // MAIN CONTENT
            // =========================

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildSpinCard(context),

                  const SizedBox(height: 22),

                  _buildInstagramStoryCard(),

                  const SizedBox(height: 28),

                  _buildSectionTitle(context),

                  const SizedBox(height: 12),

                  _buildTransactionCard(),

                  const SizedBox(height: 20),
                ],
              ),
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
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${widget.userName} 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Senang melihatmu lagi!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: softBrown,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: lightBrown,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    darkBrown.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: widget.profileImage != null
                ? Image.memory(
                    widget.profileImage!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SPIN & WIN
  // =========================================================

  Widget _buildSpinCard(BuildContext context) {
    final bool canSpin = _spinChance > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                primaryColor.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: -65,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🎁  SPIN & WIN',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                'Putar dan menangkan\nvoucher menarik!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isLoadingSpin
                    ? 'Memeriksa kesempatan spin...'
                    : canSpin
                        ? 'Kamu punya $_spinChance kesempatan spin.'
                        : 'Kesempatan spin kamu sudah habis.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color:
                      Colors.white.withValues(
                    alpha: 0.82,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: canSpin
                      ? () => _showSpinDialog(context)
                      : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.white.withValues(
                      alpha: 0.35,
                    ),
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    canSpin
                        ? 'Spin Sekarang'
                        : 'Kesempatan Habis',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                      color: canSpin
                          ? primaryColor
                          : Colors.white
                              .withValues(
                            alpha: 0.8,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SHOW SPIN DIALOG
  // =========================================================

  void _showSpinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor:
          Colors.black.withValues(alpha: 0.60),
      builder: (context) {
        return SpinDialog(
          spinChance: _spinChance,
          transaksiId: _transaksiIdUntukSpin,
          buktiIgStoryId: _buktiIgStoryIdUntukSpin,
          spinService: _spinService,
          onSpinFinished: _loadSpinStatus,
        );
      },
    );
  }

  // =========================================================
  // INSTAGRAM STORY
  // =========================================================

  Widget _buildInstagramStoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              lightBrown.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color:
                darkBrown.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
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
                  color:
                      primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Instagram Story',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Dapatkan 1 kesempatan spin',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: softBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Masukkan link Instagram Story kamu',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _instagramController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText:
                  'https://instagram.com/stories/...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 11,
                color: softBrown,
              ),
              filled: true,
              fillColor: backgroundColor,
              prefixIcon: const Icon(
                Icons.link_rounded,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isSubmittingInstagram
                  ? null
                  : () {
                      _submitInstagramStory(
                        _instagramController.text,
                      );
                    },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: _isSubmittingInstagram
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Kirim untuk Dicek',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
            ),
          ),

          if (_instagramStatus != null) ...[
            const SizedBox(height: 12),
            _buildInstagramStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildInstagramStatus() {
    String text;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (_instagramStatus) {
      case 'pending':
        text = 'Menunggu verifikasi admin';
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.hourglass_top_rounded;
        break;

      case 'diterima':
        text = 'Bukti Instagram sudah diterima ✓';
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle_rounded;
        break;

      case 'ditolak':
        text = 'Bukti Instagram ditolak';
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel_rounded;
        break;

      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SHOW MESSAGE
  // =========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showInstagramStatusDialog(String status) {
    if (!mounted) return;

    String title;
    String message;
    IconData icon;
    Color iconColor;

    switch (status) {
      case 'diterima':
        title = 'Bukti Instagram Diterima 🎉';
        message =
            'Link Instagram Story kamu sudah diverifikasi admin. '
            'Kamu sekarang bisa menggunakan kesempatan spin.';
        icon = Icons.check_circle_rounded;
        iconColor = Colors.green;
        break;

      case 'ditolak':
        title = 'Bukti Instagram Ditolak';
        message =
            'Link Instagram Story kamu belum bisa diverifikasi. '
            'Silakan cek kembali link yang dikirim.';
        icon = Icons.cancel_rounded;
        iconColor = Colors.red;
        break;

      case 'pending':
        title = 'Menunggu Verifikasi';
        message =
            'Link Instagram Story kamu sudah berhasil dikirim. '
            'Tunggu verifikasi dari admin ya.';
        icon = Icons.hourglass_top_rounded;
        iconColor = Colors.orange;
       break;

      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 58,
                color: iconColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: softBrown,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _buildSectionTitle(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transaksi Terakhir',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: darkBrown,
          ),
        ),

        GestureDetector(
          onTap: widget.onLihatSemuaTransaksi,
          child: Row(
            children: [
              Text(
                'Lihat semua',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 3),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // TRANSACTION CARD
  // =========================================================

  Widget _buildTransactionCard() {
    if (_isLoadingTransaction) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          vertical: 35,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                lightBrown.withValues(alpha: 0.7),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_latestTransaction == null) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color:
                lightBrown.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color:
                    primaryColor.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: primaryColor,
                size: 25,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Belum ada transaksi',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: darkBrown,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              'Transaksi kamu akan muncul di sini.',
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

    final transaction = _latestTransaction!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              lightBrown.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color:
                darkBrown.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: primaryColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction
                          .detailTransaksis
                          .map(
                            (detail) =>
                                detail.namaProduk ??
                                'Produk',
                          )
                          .join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: softBrown,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatDate(
                        transaction
                            .tanggalTransaksi,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: softBrown,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors.green.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  'Selesai',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color:
                        Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Divider(
            height: 1,
            color:
                lightBrown.withValues(alpha: 0.45),
          ),

          const SizedBox(height: 13),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total transaksi',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: softBrown,
                ),
              ),

              Text(
                _formatRupiah(
                  transaction.totalTransaksi,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
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

// ============================================================================
// SPIN DIALOG
// ============================================================================

class SpinDialog extends StatefulWidget {
  final int spinChance;
  final int? transaksiId;
  final int? buktiIgStoryId;
  final SpinService spinService;
  final Future<void> Function() onSpinFinished;

  const SpinDialog({
    super.key,
    required this.spinChance,
    required this.transaksiId,
    required this.buktiIgStoryId,
    required this.spinService,
    required this.onSpinFinished,
  });

  @override
  State<SpinDialog> createState() =>
      _SpinDialogState();
}

class _SpinDialogState
    extends State<SpinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double _rotation = 0.0;

  bool _isSpinning = false;

  int _remainingChance = 0;

  SpinPrize? _selectedPrize;
  String? _rewardFromBackend;

  final List<SpinPrize> _prizes = const [
    SpinPrize(
      name: 'Gratis 1 porsi bakso angkringan',
      shortName: 'FREE BAKSO',
      icon: Icons.ramen_dining,
    ),
    SpinPrize(
      name: 'Gratis 1 porsi bakso telur',
      shortName: 'FREE TELUR',
      icon: Icons.ramen_dining,
    ),
    SpinPrize(
      name: 'Gratis 1 minuman es teh',
      shortName: 'FREE ES TEH',
      icon: Icons.local_drink,
    ),
    SpinPrize(
      name: 'Diskon 10% untuk transaksi berikutnya',
      shortName: 'DISKON 10%',
      icon: Icons.discount,
    ),
    SpinPrize(
      name: 'Diskon 15% untuk transaksi berikutnya',
      shortName: 'DISKON 15%',
      icon: Icons.local_offer,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _remainingChance = widget.spinChance;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _controller.addStatusListener(
      (status) {
        if (status ==
            AnimationStatus.completed) {
          _finishSpin();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // START SPIN
  // =========================================================

  Future<void> _startSpin() async {
    if (_isSpinning ||
        _remainingChance <= 0) {
      return;
    }

    if (widget.transaksiId == null &&
        widget.buktiIgStoryId == null) {
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    try {
      final response =
          await widget.spinService.spin(
        transaksiId: widget.transaksiId,
        buktiIgStoryId: widget.buktiIgStoryId,
      );

      final data =
          response['data'] as Map<String, dynamic>;

      final voucher =
          data['voucher']
              as Map<String, dynamic>?;

      final reward =
          voucher?['keterangan']?.toString() ??
              'Reward';

      _rewardFromBackend = reward;

      final selectedIndex =
          _prizes.indexWhere(
        (prize) =>
            prize.name.toLowerCase() ==
            reward.toLowerCase(),
      );

      final safeIndex =
          selectedIndex >= 0
              ? selectedIndex
              : 0;

      final double sectionAngle =
          (2 * math.pi) /
              _prizes.length;

      final double selectedPrizeCenter =
          -math.pi / 2 +
              (safeIndex * sectionAngle) +
              (sectionAngle / 2);

      final double targetRotation =
          (6 * 2 * math.pi) +
              (-math.pi / 2 -
                  selectedPrizeCenter);

      final double startRotation =
          _rotation;

      setState(() {
        _selectedPrize =
            _prizes[safeIndex];
      });

      _controller.reset();

      late Animation<double> animation;

      animation = Tween<double>(
        begin: startRotation,
        end: startRotation +
            targetRotation,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      animation.addListener(() {
        if (!mounted) return;

        setState(() {
          _rotation = animation.value;
        });
      });

      _controller.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSpinning = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  // =========================================================
  // FINISH SPIN
  // =========================================================

  void _finishSpin() {
    if (!mounted) return;

    setState(() {
      _isSpinning = false;

      if (_remainingChance > 0) {
        _remainingChance--;
      }
    });

    _showResult();
  }

  // =========================================================
  // SHOW RESULT
  // =========================================================

  void _showResult() {
    if (_selectedPrize == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFFFFBF5),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(25),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFF4E1D3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedPrize!.icon,
                  color:
                      const Color(
                    0xFF9A4E25,
                  ),
                  size: 36,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'SELAMAT! 🎉',
                style:
                    GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      const Color(
                    0xFF4A2A1A,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Kamu mendapatkan',
                style:
                    GoogleFonts.poppins(
                  fontSize: 12,
                  color:
                      const Color(
                    0xFF927663,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                _rewardFromBackend ??
                    _selectedPrize!.name,
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      const Color(
                    0xFF9A4E25,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Reward kamu akan tersimpan di Voucher.',
                textAlign:
                    TextAlign.center,
                style:
                    GoogleFonts.poppins(
                  fontSize: 11,
                  color:
                      const Color(
                    0xFF927663,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 43,
                child:
                    ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    await widget
                        .onSpinFinished();
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF9A4E25,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),
                  child: Text(
                    'Oke, Sip!',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // BUILD DIALOG
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool noChance =
        _remainingChance <= 0;

    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 30,
      ),
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          15,
          20,
          22,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFFFFF5E6),
          borderRadius:
              BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPIN & WIN 🎡',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              const Color(
                            0xFF4A2A1A,
                          ),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Putar rodanya dan dapatkan hadiah!',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 10,
                          color:
                              const Color(
                            0xFF927663,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: _isSpinning
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                          );
                        },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color:
                          Color(0xFF927663),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration:
                  BoxDecoration(
                color: noChance
                    ? const Color(0xFFE0E0E0)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .local_fire_department_rounded,
                    color: noChance
                        ? Colors.grey.shade600
                        : const Color(
                            0xFF9A4E25,
                          ),
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    noChance
                        ? 'Kesempatan spin habis'
                        : 'Kesempatan spin: $_remainingChance',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: noChance
                          ? Colors.grey.shade700
                          : const Color(
                              0xFF4A2A1A,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 300,
              height: 325,
              child: Stack(
                alignment:
                    Alignment.topCenter,
                children: [
                  Positioned(
                    top: 20,
                    child:
                        Transform.rotate(
                      angle: _rotation,
                      child:
                          SizedBox(
                        width: 285,
                        height: 285,
                        child:
                            CustomPaint(
                          painter:
                              SpinWheelPainter(
                            prizes:
                                _prizes,
                            disabled:
                                noChance,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    child:
                        SizedBox(
                      width: 48,
                      height: 58,
                      child:
                          CustomPaint(
                        painter:
                            PointerPainter(
                          color: noChance
                              ? Colors
                                  .grey
                                  .shade600
                              : const Color(
                                  0xFF9A4E25,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            SizedBox(
              width: 155,
              height: 48,
              child:
                  ElevatedButton(
                onPressed:
                    noChance ||
                            _isSpinning
                        ? null
                        : _startSpin,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF9A4E25,
                  ),
                  disabledBackgroundColor:
                      Colors.grey.shade400,
                  foregroundColor:
                      Colors.white,
                  elevation: 3,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                child: Text(
                  _isSpinning
                      ? 'MEMUTAR...'
                      : noChance
                          ? 'SUDAH HABIS'
                          : 'PUTAR 🎁',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              noChance
                  ? 'Kesempatan spin kamu sudah habis.'
                  : 'Setiap spin menggunakan 1 kesempatan.',
              style:
                  GoogleFonts.poppins(
                fontSize: 10,
                color:
                    const Color(0xFF927663),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SPIN PRIZE MODEL
// ============================================================================

class SpinPrize {
  final String name;
  final String shortName;
  final IconData icon;

  const SpinPrize({
    required this.name,
    required this.shortName,
    required this.icon,
  });
}

// ============================================================================
// SPIN WHEEL PAINTER
// ============================================================================

class SpinWheelPainter extends CustomPainter {
  final List<SpinPrize> prizes;
  final bool disabled;

  SpinWheelPainter({
    required this.prizes,
    required this.disabled,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double radius =
        math.min(
              size.width,
              size.height,
            ) /
            2;

    final double sectionAngle =
        (2 * math.pi) /
            prizes.length;

    final List<Color> colors = [
      const Color(0xFF9A4E25),
      const Color(0xFFD88B58),
      const Color(0xFFE8B98E),
      const Color(0xFFB96B3D),
      const Color(0xFFF0D2B5),
    ];

    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    for (
      int i = 0;
      i < prizes.length;
      i++
    ) {
      paint.color = disabled
          ? const Color(0xFFBDBDBD)
          : colors[i];

      final double startAngle =
          -math.pi / 2 +
              i * sectionAngle;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      final Paint dividerPaint =
          Paint()
            ..style =
                PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        sectionAngle,
        true,
        dividerPaint,
      );
    }

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = disabled
          ? const Color(0xFF8E8E8E)
          : const Color(0xFF4A2A1A);

    canvas.drawCircle(
      center,
      radius - 3,
      borderPaint,
    );

    for (
      int i = 0;
      i < prizes.length;
      i++
    ) {
      final double angle =
          -math.pi / 2 +
              i * sectionAngle +
              sectionAngle / 2;

      final double textRadius =
          radius * 0.64;

      final Offset textPosition =
          Offset(
        center.dx +
            math.cos(angle) *
                textRadius,
        center.dy +
            math.sin(angle) *
                textRadius,
      );

      canvas.save();

      canvas.translate(
        textPosition.dx,
        textPosition.dy,
      );

      canvas.rotate(
        angle + math.pi / 2,
      );

      final TextPainter iconPainter =
          TextPainter(
        text: TextSpan(
          text: String.fromCharCode(
            prizes[i].icon.codePoint,
          ),
          style: TextStyle(
            fontFamily:
                prizes[i].icon.fontFamily,
            package:
                prizes[i].icon.fontPackage,
            fontSize: 23,
            color: disabled
                ? const Color(0xFF777777)
                : Colors.white,
          ),
        ),
        textDirection:
            TextDirection.ltr,
      );

      iconPainter.layout();

      iconPainter.paint(
        canvas,
        Offset(
          -iconPainter.width / 2,
          -29,
        ),
      );

      final TextPainter textPainter =
          TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: prizes[i].shortName,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: disabled
                ? const Color(0xFF777777)
                : (i == 4
                    ? const Color(
                        0xFF4A2A1A,
                      )
                    : Colors.white),
          ),
        ),
        textDirection:
            TextDirection.ltr,
      );

      textPainter.layout(
        maxWidth: 68,
      );

      textPainter.paint(
        canvas,
        Offset(
          -textPainter.width / 2,
          2,
        ),
      );

      canvas.restore();
    }

    final Paint centerPaint =
        Paint()
          ..color = disabled
              ? const Color(0xFF9E9E9E)
              : const Color(0xFFFFFBF5);

    canvas.drawCircle(
      center,
      37,
      centerPaint,
    );

    final Paint centerBorder =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = disabled
              ? const Color(0xFF777777)
              : const Color(0xFF4A2A1A);

    canvas.drawCircle(
      center,
      37,
      centerBorder,
    );

    final TextPainter centerText =
        TextPainter(
      text: const TextSpan(
        text: 'PUTAR',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF9A4E25),
        ),
      ),
      textDirection:
          TextDirection.ltr,
    );

    centerText.layout();

    centerText.paint(
      canvas,
      Offset(
        center.dx -
            centerText.width / 2,
        center.dy -
            centerText.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(
    covariant SpinWheelPainter oldDelegate,
  ) {
    return oldDelegate.disabled !=
        disabled;
  }
}

// ============================================================================
// POINTER
// ============================================================================

class PointerPainter extends CustomPainter {
  final Color color;

  PointerPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint outlinePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final Path outlinePath = Path();

    outlinePath.moveTo(
      size.width / 2,
      size.height,
    );

    outlinePath.lineTo(
      1,
      2,
    );

    outlinePath.lineTo(
      size.width - 1,
      2,
    );

    outlinePath.close();

    canvas.drawPath(
      outlinePath,
      outlinePaint,
    );

    final Paint pointerPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final Path pointerPath = Path();

    pointerPath.moveTo(
      size.width / 2,
      size.height - 3,
    );

    pointerPath.lineTo(
      7,
      6,
    );

    pointerPath.quadraticBezierTo(
      size.width / 2,
      14,
      size.width - 7,
      6,
    );

    pointerPath.close();

    canvas.drawPath(
      pointerPath,
      pointerPaint,
    );

    final Paint circlePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        size.width / 2,
        14,
      ),
      4,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant PointerPainter oldDelegate,
  ) {
    return oldDelegate.color != color;
  }
}