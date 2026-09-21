import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final AuthService _authService = AuthService();

  static const Color backgroundColor = Color(0xFFFFF5E6);
  static const Color primaryColor = Color(0xFF9A4E25);
  static const Color darkBrown = Color(0xFF4A2A1A);
  static const Color borderColor = Color(0xFFE6CDB4);
  static const Color hintColor = Color(0xFF9A8D84);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  try {
    await _authService.register(
      nama: _nameController.text.trim(),
      noHp: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      kodeReferral: _referralController.text.trim().isEmpty
        ? null
        : _referralController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil!'),
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      '/login',
      arguments: 'Registrasi berhasil.',
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
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -80,
            child: _backgroundCircle(
              size: 240,
              color: const Color(0xFFF3D3AA),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,
            child: _backgroundCircle(
              size: 280,
              color: const Color(0xFFF0D7B7),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // =========================
                        // BACK BUTTON
                        // =========================
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: darkBrown,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // =========================
                        // LOGO
                        // =========================
                        Container(
                          width: 125,
                          height: 125,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFB96632),
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/Bakso Angkringan Logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =========================
                        // TITLE
                        // =========================
                        Text(
                          'Bikin Akun Yuk!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: darkBrown,
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          'Daftar sekarang dan mulai nikmati\n'
                          'serunya Bakso & Kopi Angkringan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6F5A4D),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // =========================
                        // NAMA
                        // =========================
                        _fieldLabel('Nama'),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: 'Masukkan nama kamu',
                            icon: Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nama wajib diisi';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =========================
                        // NOMOR HP
                        // =========================
                        _fieldLabel('Nomor HP'),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            hint: 'Masukkan nomor HP',
                            icon: Icons.phone_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Nomor HP wajib diisi';
                            }

                            if (value.trim().length < 10) {
                              return 'Nomor HP tidak valid';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =========================
                        // PASSWORD
                        // =========================
                        _fieldLabel('Password'),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            hint: 'Buat password',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }

                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =========================
                        // KONFIRMASI PASSWORD
                        // =========================
                        _fieldLabel('Konfirmasi Password'),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: _inputDecoration(
                            hint: 'Masukkan ulang password',
                            icon: Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password wajib diisi';
                            }

                            if (value != _passwordController.text) {
                              return 'Password tidak sama';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =========================
                        // REFERRAL
                        // =========================
                        _fieldLabel(
                          'Kode Referral',
                          optional: true,
                        ),

                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _referralController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration(
                            hint: 'Masukkan kode referral',
                            icon: Icons.card_giftcard_outlined,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // REGISTER BUTTON
                        // =========================
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor:
                                  primaryColor.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 21,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // =========================
                        // LOGIN LINK
                        // =========================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(
                                color: Color(0xFF6F5A4D),
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: primaryColor,
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                                                const SizedBox(height: 20),

                        // =========================
                        // FOOTER
                        // =========================
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 35,
                              height: 1,
                              color: const Color(0xFFD5B99A),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'Angkringan',
                                style: TextStyle(
                                  color: Color(0xFF927663),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              width: 35,
                              height: 1,
                              color: const Color(0xFFD5B99A),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // FIELD LABEL
  // =========================

  Widget _fieldLabel(
    String text, {
    bool optional = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          children: [
            if (optional)
              const TextSpan(
                text: '  (opsional)',
                style: TextStyle(
                  color: Color(0xFF9A8D84),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INPUT DECORATION
  // =========================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: hintColor,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: primaryColor,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFCF8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _backgroundCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.35),
      ),
    );
  }
}