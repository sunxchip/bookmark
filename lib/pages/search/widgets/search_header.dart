import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';

/// 상단 검색창 (프리뷰 전용: readOnly)
/// TODO: 추후 실제 검색 기능 붙일 때 readOnly 제거 + onSubmitted/onChanged 연결
class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: const [
          Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                hintText: '지금 읽을 책 검색',
                hintStyle: TextStyle(
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w600, // SemiBold
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
