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
final Set<String> _askedTotalPagesOnce = <String>{};

class ReadingDetailView extends StatefulWidget {
  final ReadingSession session;
  const ReadingDetailView({super.key, required this.session});

  @override
  State<ReadingDetailView> createState() => _ReadingDetailViewState();
}

class _ReadingDetailViewState extends State<ReadingDetailView> {
  bool _asking = false;           // 현재 다이얼로그 표시 중인지
  String? _lastAskedBookId;       // 같은 프레임에서 중복 호출 방지

  @override
  void initState() {
    super.initState();
    // 첫 프레임 끝나고 팝업 체크
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskTotalPages());
  }

  @override
  void didUpdateWidget(covariant ReadingDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 다른 책으로 전환되었으면 컨트롤러를 재초기화하여 세션 전환 보장
    if (oldWidget.session.book.isbn13 != widget.session.book.isbn13) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final ctrl = context.read<ReadingDetailController>();
        await ctrl.init(widget.session);   // ← 재초기화(내서재/진행률/로그 동기)

        // 전환된 책에 대해 총 페이지 입력 유도(한 번만)
        await _maybeAskTotalPages();
      });
    }
  }

  Future<void> _maybeAskTotalPages() async {
    if (!mounted) return;

    final c = context.read<ReadingDetailController>();
    final bookId = c.isbn13;
    final total = c.totalPages ?? 0;

    // 총 페이지가 이미 있거나, 이미 물어봤거나, 지금 띄우는 중이면 패스
    if (total > 0) return;
    if (_askedTotalPagesOnce.contains(bookId)) return;
    if (_asking) return;
    if (_lastAskedBookId == bookId) return;

    _asking = true;
    _lastAskedBookId = bookId;

    final input = await _askTotalPagesDialog(context, c.totalPages);
    _asking = false;

    if (!mounted) return;
    if (input != null && input > 0) {
      await c.setTotalPages(input); // 저장/동기화 보장
    }
    // 취소여도 두 번 뜨는 것 방지
    _askedTotalPagesOnce.add(bookId);
  }

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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
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
    // 컨트롤러는 한 번 생성 후 유지됨. 세션 전환 시 didUpdateWidget에서 init 재호출.
    return ChangeNotifierProvider(
      create: (_) => ReadingDetailController()..init(widget.session),
      builder: (context, _) {
        final c = context.watch<ReadingDetailController>();

        // 전역 NotoSans 적용
        final textThemeNoto = Theme.of(context).textTheme.apply(fontFamily: 'NotoSans');

        final total = c.totalPages ?? 0;
        final progress = (total <= 0)
            ? 0.0
            : (c.currentPage / max(1, total)).clamp(0, 1).toDouble();

        return DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(fontFamily: 'NotoSans'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 진행도
                ProgressHeader(progress: progress),
                const SizedBox(height: 16),

                // 책 헤더(표지/제목/작가/총페이지)
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

                // 타이머
                Text('독서 시간 기록', style: textThemeNoto.titleMedium),
                const SizedBox(height: 8),
                ReadingTimerCard(
                  initialPage: c.currentPage,
                  totalPages: c.totalPages,
                  // 저장 시: 컨트롤러에 위임 → Repo 반영, 타이머 리셋은 카드 내부 처리
                  onSaved: (elapsed, page, memo) =>
                      c.saveLog(elapsed, reachedPage: page, memo: memo),
                ),

                const SizedBox(height: 24),

                // 기록 그리드 (한 줄 3칸, 탭 시 상세/삭제 시트)
                Text('나의 독서 기록', style: textThemeNoto.titleMedium),
                const SizedBox(height: 8),
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
    );
  }
}
