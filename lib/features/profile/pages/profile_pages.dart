import 'dart:convert';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../authentication/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String nama;
  final String noHp;
  final String kodeReferral;
  final Uint8List? profileImage;
  final ValueChanged<Uint8List?> onProfileImageChanged;

  const ProfilePage({
    super.key,
    required this.nama,
    required this.noHp,
    required this.kodeReferral,
    required this.profileImage,
    required this.onProfileImageChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color backgroundColor = Color(0xFFFFF5E6);
  static const Color primaryColor = Color(0xFF9A4E25);
  static const Color darkBrown = Color(0xFF4A2A1A);
  static const Color softBrown = Color(0xFF927663);
  static const Color lightBrown = Color(0xFFD5B99A);
  static const Color cardColor = Color(0xFFFFFBF5);
  static const Color borderColor = Color(0xFFE6CDB4);

  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();


  Uint8List? _profileImage;
  bool _isLoggingOut = false;

  String get _profileImageKey => 'profile_image_${widget.noHp}';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedImage = prefs.getString(_profileImageKey);

    if (savedImage == null || savedImage.isEmpty) {
      return;
    }

    try {
      final imageBytes = base64Decode(savedImage);

      if (!mounted) return;

      setState(() {
        _profileImage = imageBytes;
      });

      widget.onProfileImageChanged(imageBytes);
    } catch (e) {
      print('ERROR LOAD FOTO PROFIL: $e');
    }
  }

  Future<void> _changeProfilePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _profileImageKey,
      base64Image,
    );

    if (!mounted) return;

    setState(() {
      _profileImage = bytes;
    });

    widget.onProfileImageChanged(bytes);
  }

  Future<void> _copyReferralCode() async {
    await Clipboard.setData(
      ClipboardData(text: widget.kodeReferral),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode referral berhasil disalin.'),
      ),
    );
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text(
            'Keluar dari akun?',
            style: GoogleFonts.poppins(
              color: darkBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Kamu harus login kembali untuk mengakses akunmu.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _logout();
    }
  }

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
          // CONTENT
          // =========================

            Column(
              children: [
                _buildHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),

                        _buildProfilePhoto(),

                        const SizedBox(height: 16),

                        Text(
                          widget.nama,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: darkBrown,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Data profil kamu',
                          style: GoogleFonts.poppins(
                            color: softBrown,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 28),

                        _infoCard(
                          icon: Icons.person_outline_rounded,
                          title: 'Nama',
                          value: widget.nama,
                        ),

                        const SizedBox(height: 12),

                        _infoCard(
                          icon: Icons.phone_outlined,
                          title: 'Nomor HP',
                          value: widget.noHp,
                        ),

                        const SizedBox(height: 12),

                        _referralCard(),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isLoggingOut
                            ? null
                            : _showLogoutConfirmation,
                            icon: _isLoggingOut
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(
                              Icons.logout_rounded,
                              size: 20,
                            ),
                            label: Text(
                              _isLoggingOut
                              ? 'Keluar...'
                              : 'Keluar dari Akun',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: const BorderSide(
                                color: primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
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
            'Profil',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola informasi akun kamu',
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

  Widget _buildProfilePhoto() {
    return Stack(
      children: [
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardColor,
            border: Border.all(
              color: lightBrown,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: darkBrown.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: _profileImage != null
                ? Image.memory(
                    _profileImage!,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 62,
                    color: Color(0xFFD0B49B),
                  ),
          ),
        ),

        Positioned(
          right: 0,
          bottom: 2,
          child: Material(
            color: primaryColor,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _changeProfilePhoto,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF7E4D1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF927663),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF7E4D1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kode Referral',
                  style: TextStyle(
                    color: Color(0xFF927663),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.kodeReferral,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _copyReferralCode,
            tooltip: 'Salin kode',
            icon: const Icon(
              Icons.copy_rounded,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
