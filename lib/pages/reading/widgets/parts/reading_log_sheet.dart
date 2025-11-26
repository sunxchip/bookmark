import 'package:flutter/material.dart';
import 'package:bookmark/features/reading/application/reading_detail_controller.dart';

class ReadingLogActionSheet extends StatelessWidget {
  const ReadingLogActionSheet({
    super.key,
    required this.bookTitle,
    required this.coverUrl,
    required this.log,
    required this.onDelete,
  });

  final String bookTitle;
  final String coverUrl;
  final ReadingLogVm log;
  final VoidCallback onDelete;

  static Future<void> show(
      BuildContext context, {
        required String bookTitle,
        required String coverUrl,
        required ReadingLogVm log,
        required VoidCallback onDelete,
      }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: ReadingLogActionSheet(
          bookTitle: bookTitle,
          coverUrl: coverUrl,
          log: log,
          onDelete: onDelete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mins = log.duration.inMinutes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 책 정보
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coverUrl,
                  width: 44,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  bookTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 요약
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${log.createdAt.month}월 ${log.createdAt.day}일 • ${mins}분 • P.${log.reachedPage}',
            ),
          ),
          const SizedBox(height: 8),

          // 메모
          if ((log.memo ?? '').isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(log.memo!),
            ),

          const SizedBox(height: 16),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('뒤로가기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await Future<void>.delayed(const Duration(milliseconds: 0));
                    onDelete();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('기록 삭제'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
