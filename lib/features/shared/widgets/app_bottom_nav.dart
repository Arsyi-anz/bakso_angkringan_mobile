import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(
            color: AppColors.lightBrown.withValues(alpha: 0.45),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(
              index: 0,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildItem(
              index: 1,
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'Transaksi',
            ),
            _buildItem(
              index: 2,
              icon: Icons.confirmation_num_outlined,
              activeIcon: Icons.confirmation_num_rounded,
              label: 'Voucher',
            ),
            _buildItem(
              index: 3,
              icon: Icons.card_giftcard_outlined,
              activeIcon: Icons.card_giftcard_rounded,
              label: 'Reward',
            ),
            _buildItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (index != currentIndex) {
            onItemTapped(index);
          }
        },
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.softBrown,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.softBrown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}