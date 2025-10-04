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
    return ChangeNotifierProvider(
      create: (_) => ReadingTimerViewModel(),
      child: _TimerBody(
        onSaved: onSaved,
        initialPage: initialPage,
        totalPages: totalPages,
      ),
    );
  }
}

class _TimerBody extends StatelessWidget {
  const _TimerBody({
    required this.onSaved,
    this.initialPage,
    this.totalPages,
  });

  final ReadingSaved? onSaved;
  final int? initialPage;
  final int? totalPages;

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  Future<void> _handleTap(BuildContext context) async {
    final vm = context.read<ReadingTimerViewModel>();

    if (!vm.isRunning) {
      // ▶️ 시작 알림
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

    // ⏸ 중단: 바텀 시트로 기록 입력 받기
    final result = await ReadingLogSheet.show(
      context,
      elapsed: vm.elapsed,
      initialPage: initialPage,
      totalPages: totalPages,
    );

    if (result != null) {
      vm.pause();
      onSaved?.call(vm.elapsed, result.page, result.memo);
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
