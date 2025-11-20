import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/reading/application/reading_detail_controller.dart';

import 'package:bookmark/pages/widgets/orange_divider.dart';
import 'package:bookmark/pages/reading/widgets/reading_timer_card.dart';
import 'package:bookmark/pages/reading/widgets/parts/progress_header.dart';
import 'package:bookmark/pages/reading/widgets/parts/book_header.dart';

class ReadingDetailView extends StatelessWidget {
  final ReadingSession session;
  const ReadingDetailView({super.key, required this.session});

  Future<int?> _askTotalPagesDialog(BuildContext context, int? initial) async {
    final c = TextEditingController(text: (initial == null || initial == 0) ? '' : '$initial');
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('쪽수 확인이 필요해요'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '총 페이지 입력'),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: (){
              final n = int.tryParse(c.text.trim());
              Navigator.pop(context, (n != null && n > 0) ? n : null);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReadingDetailController()..init(session),
      builder: (context, _) {
        final c = context.watch<ReadingDetailController>();

        final textTheme = Theme.of(context).textTheme.apply(fontFamily: 'NotoSans');

        // 진입 시 총페이지 없으면 한 번만 입력 유도
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if ((c.totalPages ?? 0) == 0) {
            final n = await _askTotalPagesDialog(context, c.totalPages);
            if (n != null) c.setTotalPages(n);
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressHeader(progress: c.progress),
              const SizedBox(height: 16),

              BookHeader(
                coverUrl: c.cover,
                title: c.title,
                author: c.author,
                isbn13: c.isbn13,
                totalPages: c.totalPages,
                onAskTotalPages: () async {
                  final n = await _askTotalPagesDialog(context, c.totalPages);
                  if (n != null) c.setTotalPages(n);
                  return n;
                },
              ),

              const SizedBox(height: 20),
              const OrangeDivider(),
              const SizedBox(height: 12),

              Text('독서 시간 기록', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ReadingTimerCard(
                initialPage: c.currentPage,
                totalPages: c.totalPages,
                onSaved: (elapsed, page, memo) => c.saveLog(elapsed, reachedPage: page, memo: memo),
              ),

              const SizedBox(height: 24),
              Text('나의 독서 기록', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: c.logs.isEmpty
                    ? const Text('아직 기록이 없습니다.')
                    : Wrap(
                  spacing: 12, runSpacing: 12,
                  children: c.logs.map((e) {
                    final d = '${e.createdAt.month}월 ${e.createdAt.day}일';
                    final h = e.duration.inHours;
                    final m = e.duration.inMinutes % 60;
                    final dur = h > 0 ? '${h}시간 ${m}분' : '${e.duration.inMinutes}분';
                    return _Chip('$d • $dur • P.${e.reachedPage}');
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
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
