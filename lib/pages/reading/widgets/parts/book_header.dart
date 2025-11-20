import 'package:flutter/material.dart';

class BookHeader extends StatelessWidget {
  final String coverUrl, title, author, isbn13;
  final int? totalPages;
  final Future<int?> Function() onAskTotalPages; // 다이얼로그는 View가 띄우고, 결과만 콜백
  const BookHeader({
    super.key,
    required this.coverUrl,
    required this.title,
    required this.author,
    required this.isbn13,
    required this.totalPages,
    required this.onAskTotalPages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(coverUrl, height: 160, width: 120, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(author, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ISBN-13 $isbn13', style: theme.textTheme.bodySmall),
              const SizedBox(width: 6),
              if ((totalPages ?? 0) > 0)
                Text('• ${totalPages}p', style: theme.textTheme.bodySmall)
              else
                TextButton.icon(
                  onPressed: () async => await onAskTotalPages(),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('총 페이지 설정'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
