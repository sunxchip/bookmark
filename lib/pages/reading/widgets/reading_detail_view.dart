import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/reading/application/reading_detail_controller.dart';

import 'package:bookmark/pages/widgets/orange_divider.dart';
import 'package:bookmark/pages/reading/widgets/reading_timer_card.dart';
import 'package:bookmark/pages/reading/widgets/parts/progress_header.dart';
import 'package:bookmark/pages/reading/widgets/parts/book_header.dart';
import 'package:bookmark/pages/reading/widgets/parts/reading_log_grid.dart';

/// 앱 실행 중(프로세스 생존 동안) 같은 책에 대해 총 페이지 다이얼로그를
/// 이미 한 번 띄웠는지 기록 (중복 표시 방지)
final Set<String> _askedOnce = <String>{};

class ReadingDetailView extends StatefulWidget {
  final ReadingSession session;
  const ReadingDetailView({super.key, required this.session});

  @override
  State<ReadingDetailView> createState() => _ReadingDetailViewState();
}

class _ReadingDetailViewState extends State<ReadingDetailView> {
  bool _askedInThisBuild = false; // 빌드 사이클당 1회만 팝업

  Future<int?> _askTotalPagesDialog(BuildContext context, int? initial) async {
    final ctrl = TextEditingController(
      text: (initial == null || initial == 0) ? '' : '$initial',
    );
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('쪽수 확인이 필요해요'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '총 페이지 입력'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              Navigator.of(context).pop((n != null && n > 0) ? n : null);
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
      create: (_) => ReadingDetailController()..init(widget.session),
      child: Builder(
        builder: (context) {
          final c = context.watch<ReadingDetailController>();

          // ⚠️ 팝업은 Provider가 생긴 "이후" 프레임에서만 띄운다.
          if (!_askedInThisBuild) {
            final bookId = c.isbn13;
            final total = c.totalPages ?? 0;
            if (bookId.isNotEmpty && total == 0 && !_askedOnce.contains(bookId)) {
              _askedInThisBuild = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                final n = await _askTotalPagesDialog(context, c.totalPages);
                if (!mounted) return;
                if (n != null) {
                  await c.setTotalPages(n); // 반드시 await
                }
                _askedOnce.add(bookId);
              });
            }
          }

          final theme = Theme.of(context);
          final total = c.totalPages ?? 0;
          final progress = total <= 0 ? 0.0 : (c.currentPage / total).clamp(0, 1).toDouble();

          return DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(fontFamily: 'NotoSans'),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressHeader(progress: progress),
                  const SizedBox(height: 16),
                  BookHeader(
                    coverUrl: c.cover,
                    title: c.title,
                    author: c.author,
                    isbn13: c.isbn13,
                    totalPages: c.totalPages,
                    onAskTotalPages: () async {
                      final n = await _askTotalPagesDialog(context, c.totalPages);
                      if (n != null) await c.setTotalPages(n);
                      return n;
                    },
                  ),
                  const SizedBox(height: 20),
                  const OrangeDivider(),
                  const SizedBox(height: 12),
                  Text('독서 시간 기록', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ReadingTimerCard(
                    initialPage: c.currentPage,
                    totalPages: c.totalPages,
                    onSaved: (elapsed, page, memo) =>
                        c.saveLog(elapsed, reachedPage: page, memo: memo),
                  ),
                  const SizedBox(height: 24),
                  Text('나의 독서 기록', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  // 정사각 그리드 사용 중이면 해당 위젯으로 교체
                  ReadingLogGrid(
                    logs: c.logs,
                    bookTitle: c.title,
                    coverUrl: c.cover,
                    onDelete: (id) => c.deleteLog(id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}