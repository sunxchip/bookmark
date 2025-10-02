import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';

class ReadingEmptyView extends StatelessWidget {
  const ReadingEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 책 표지 느낌 + 플러스
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2F3036),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, size: 44, color: Color(0xFF555862)),
            ),
            const SizedBox(height: 28),
            // 큰 제목: Bold
            const Text(
              '등록된 서재가 없어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w700, // Bold
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // 작은 설명: SemiBold
            const Text(
              '내 서재에서 추가해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w600, // SemiBold
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
