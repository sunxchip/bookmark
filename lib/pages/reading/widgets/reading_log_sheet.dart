import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bookmark/nav/app_theme.dart';

class ReadingLogResult {
  final int? page;
  final String? memo;
  const ReadingLogResult({this.page, this.memo});
}

class ReadingLogSheet extends StatefulWidget {
  const ReadingLogSheet({
    super.key,
    required this.elapsed,
    this.initialPage,
    this.totalPages,
  });

  final Duration elapsed;
  final int? initialPage;
  final int? totalPages;

  static Future<ReadingLogResult?> show(
      BuildContext context, {
        required Duration elapsed,
        int? initialPage,
        int? totalPages,
      }) {
    return showModalBottomSheet<ReadingLogResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReadingLogSheet(
        elapsed: elapsed,
        initialPage: initialPage,
        totalPages: totalPages,
      ),
    );
  }

  @override
  State<ReadingLogSheet> createState() => _ReadingLogSheetState();
}

class _ReadingLogSheetState extends State<ReadingLogSheet> {
  late final TextEditingController _pageCtrl;
  final TextEditingController _memoCtrl = TextEditingController();
  bool _showMemo = false;

  @override
  void initState() {
    super.initState();
    _pageCtrl = TextEditingController(
      text: widget.initialPage != null ? '${widget.initialPage}' : '',
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final parts = <String>[];
    if (h > 0) parts.add('${h}시간');
    if (m > 0) parts.add('${m}분');
    parts.add('${s}초');
    return '${parts.join(' ')} 기록되었어요 !';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final now = DateTime.now();
    final dateText = '${now.month}월 ${now.day}일';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: max(24, bottom + 24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
              Center(
                child: Container(
                  width: 44, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text('오늘의 독서 기록 ›', style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(dateText, style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  _formatElapsed(widget.elapsed),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // 읽은 페이지 입력
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: TextField(
                    controller: _pageCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '읽은 페이지 입력',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      helperText: widget.totalPages != null
                          ? '총 ${widget.totalPages}p'
                          : null,
                      helperStyle: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ),

              if (_showMemo) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _memoCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '메모를 입력하세요 (선택)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 완료
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.orange),
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final text = _pageCtrl.text.trim();
                    int? page = text.isEmpty ? null : int.tryParse(text);
                    if (widget.totalPages != null &&
                        page != null &&
                        page > widget.totalPages!) {
                      page = widget.totalPages;
                    }
                    Navigator.of(context).pop(
                      ReadingLogResult(
                        page: page,
                        memo: _memoCtrl.text.trim().isEmpty
                            ? null
                            : _memoCtrl.text.trim(),
                      ),
                    );
                  },
                  child: const Text('완료'),
                ),
              ),
              const SizedBox(height: 10),

              // 메모 남기기 (메모 입력 토글)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.32)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => setState(() => _showMemo = true),
                  child: const Text('메모 남기기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
