import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/pages/home_pages.dart';
import '../../transaction/pages/transaction_page.dart';
import '../../voucher/pages/voucher_page.dart';
import '../../reward/pages/reward_page.dart';
import '../../profile/pages/profile_pages.dart';
import '../../shared/widgets/app_bottom_nav.dart';

class MainNavigationPage extends StatefulWidget {
  final String userName;
  final String noHp;
  final String kodeReferral;

  const MainNavigationPage({
    super.key,
    required this.userName,
    required this.noHp,
    required this.kodeReferral,
  });

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int _currentIndex = 0;

  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();

    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    final key = 'profile_image_${widget.noHp}';

    final savedImage = prefs.getString(key);

    if (savedImage == null || savedImage.isEmpty) {
      return;
    }

    try {
      final imageBytes = base64Decode(savedImage);

      if (!mounted) return;

      setState(() {
        _profileImage = imageBytes;
      });
    } catch (e) {
      print('ERROR MAIN FOTO PROFIL: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onProfileImageChanged(Uint8List? image) {
    setState(() {
      _profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        userName: widget.userName,
        noHp: widget.noHp,
        kodeReferral: widget.kodeReferral,
        profileImage: _profileImage,
        onLihatSemuaTransaksi: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),

      const TransactionPage(),

      VoucherPage(
        isActive: _currentIndex == 2,
      ),

      const RewardPage(),

      ProfilePage(
        nama: widget.userName,
        noHp: widget.noHp,
        kodeReferral: widget.kodeReferral,
        profileImage: _profileImage,
        onProfileImageChanged: _onProfileImageChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}