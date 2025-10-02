import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';

class CapsuleHeader extends StatelessWidget {
  const CapsuleHeader({
    super.key,
    required this.title,
    this.assetPath = 'assets/images/logo_icon.png',
    this.iconSize = 20,
    this.roundness = 18,
    this.minHeight = 56,
  });

  final String title;
  final String assetPath;
  final double iconSize;
  final double roundness;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(roundness),
      ),
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,

          ),
          const SizedBox(width: 12),
          const SizedBox(width: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontWeight: FontWeight.w700, // Bold
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
