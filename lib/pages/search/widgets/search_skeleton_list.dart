import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';

class SearchSkeletonList extends StatelessWidget {
  const SearchSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 8,
      separatorBuilder: (_, __) => const Divider(
        color: Color(0xFF232428), // 미묘한 구분선
        height: 1,
      ),
      itemBuilder: (_, __) => const _SkeletonItem(),
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // 썸네일 자리
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF24252B),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          // 텍스트 라인 자리
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Bar(width: 160),
                SizedBox(height: 12),
                _Bar(width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF24252B),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
