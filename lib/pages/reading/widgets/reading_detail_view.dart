import 'package:flutter/material.dart';
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/pages/widgets/orange_divider.dart';
import 'package:bookmark/pages/reading/widgets/reading_timer_card.dart';

class ReadingDetailView extends StatelessWidget {
  final ReadingSession session;
  const ReadingDetailView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final book = session.book;
    final progress = session.progress.clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행도 바
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(value: progress, minHeight: 10),
          ),
          const SizedBox(height: 8),
          Text(
            '읽기 중 ${(progress * 100).toStringAsFixed(0)} %',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),

          // 책 표지 + 제목 + 부가정보
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    book.coverUrl,
                    height: 160,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(book.author, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(
                  'ISBN-13 ${book.isbn13}${book.pageCount != null ? ' • ${book.pageCount}p' : ''}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const OrangeDivider(),
          const SizedBox(height: 12),

          // 타이머
          Text('독서 시간 기록', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ReadingTimerCard(
            initialPage: session.lastPage,     // 있으면 입력란 미리 채움
            totalPages: session.totalPages,    // 진행률 계산용 총 페이지
            onSaved: (elapsed, page, memo) {
              // TODO: 실제 저장/세션 업데이트 로직 연결
              // - 예) progress = (page ?? 0) / (session.totalPages ?? 1)
              final h = elapsed.inHours;
              final m = elapsed.inMinutes % 60;
              final s = elapsed.inSeconds % 60;
              final pageText = page != null ? ' • P.$page' : '';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('기록 저장: ${h}h ${m}m ${s}s$pageText'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 기록 섹션 (목업)
          Text('나의 독서 기록', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _Chip('23일 • 32분 • P.210'),
                _Chip('25일 • 58분 • P.186'),
                _Chip('23일 • 32분 • P.160'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.24)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
