import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookmark/nav/app_theme.dart';
import 'package:bookmark/features/reading/application/reading_timer_view_model.dart';
import 'package:bookmark/pages/reading/widgets/reading_log_sheet.dart';

/// 일시정지 확정 시
typedef ReadingSaved = void Function(Duration elapsed, int? page, String? memo);

class ReadingTimerCard extends StatelessWidget {
  const ReadingTimerCard({
    super.key,
    this.onSaved,
    this.initialPage,
    this.totalPages,
  });

  final ReadingSaved? onSaved;
  final int? initialPage;
  final int? totalPages;

  @override
  Widget build(BuildContext context) {
    // 상위(ReadingPage)에서 생성해둔 동일 VM을 재사용
    final vm = context.read<ReadingTimerViewModel>();
    return ChangeNotifierProvider<ReadingTimerViewModel>.value(
      value: vm,
      child: _TimerBody(
        onSaved: onSaved,
        initialPage: initialPage,
        totalPages: totalPages,
      ),
    );
  }
}

class _TimerBody extends StatefulWidget {
  const _TimerBody({
    required this.onSaved,
    this.initialPage,
    this.totalPages,
  });

  final ReadingSaved? onSaved;
  final int? initialPage;
  final int? totalPages;

  @override
  State<_TimerBody> createState() => _TimerBodyState();
}

class _TimerBodyState extends State<_TimerBody> {
  bool _opening = false; // 중복 탭/중복 다이얼로그 방지 가드

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_opening) return; // 이미 처리 중이면 무시
    _opening = true;

    final vm = context.read<ReadingTimerViewModel>();
    try {
      if (!vm.isRunning) {
        // ▶️ 시작
        vm.start();
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: const Text('오늘의 독서 기록이\n시작되었어요!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        return;
      }

      // ⏸ 중단 → 바텀시트 입력
      final result = await ReadingLogSheet.show(
        context,
        elapsed: vm.elapsed,
        initialPage: widget.initialPage,
        totalPages: widget.totalPages,
      );

      if (result != null) {
        // 저장 플로우: 누락분 합산 → 콜백(영속/진행률 반영) → 타이머만 00:00:00
        vm.pause();
        widget.onSaved?.call(vm.elapsed, result.page, result.memo);
        vm.reset(); // 진행률은 DB/VM에서 유지, 타이머만 리셋
      }
    } finally {
      _opening = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReadingTimerViewModel>();
    final time = _fmt(vm.elapsed);

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          InkWell(
            onTap: () => _handleTap(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                vm.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
