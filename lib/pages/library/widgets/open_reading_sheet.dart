import 'dart:async';
import 'package:flutter/material.dart';

class OpenReadingSheet {

  static Future<bool> confirm(
      BuildContext context, {
        required String title,
        required String coverUrl,
      }) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Sheet(title: title, coverUrl: coverUrl),
    );
    return ok ?? false;
  }

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String coverUrl,
        FutureOr<void> Function()? onConfirm,
      }) async {
    final ok = await confirm(context, title: title, coverUrl: coverUrl);
    if (ok && onConfirm != null) {
      // 시트가 닫힌 뒤 콜백 실행 → 네비게이션/상태 변경 안전
      await onConfirm();
    }
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.coverUrl});
  final String title;
  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coverUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.menu_book_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '“$title”을(를) 이어 읽을까요?',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 계속하기
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // 시트를 닫으면서 true 반환
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text('계속하기'),
              ),
            ),
            const SizedBox(height: 8),

            // 뒤로가기
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                child: const Text('뒤로가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
