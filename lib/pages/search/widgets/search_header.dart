import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({
    super.key,
    this.controller,
    this.readOnly = true,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                isDense: true,
                hintText: '지금 읽을 책 검색',
                hintStyle: TextStyle(
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
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
