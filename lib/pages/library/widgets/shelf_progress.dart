import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bookmark/data/repositories/sqlite_repository.dart';

/// 각 책(=bookId)의 진행률을 DB에서 '개별로' 구해 보여주는 위젯
/// ReadingViewModel을 절대 참조하지 않음
class ShelfProgress extends StatefulWidget {
  const ShelfProgress({super.key, required this.bookId, this.height = 8});
  final String bookId; // 보통 isbn13
  final double height;

  @override
  State<ShelfProgress> createState() => _ShelfProgressState();
}

class _ShelfProgressState extends State<ShelfProgress> {
  final _db = SqliteRepository.I;

  double _progress = 0.0;   // 0.0 ~ 1.0
  String _label = '현재 진행도 0%';

  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    // DB 변경 스트림 구독 → 내 bookId인 경우만 갱신
    _sub = _db.changes.listen((_) => _refresh());
    _refresh();
  }

  @override
  void didUpdateWidget(covariant ShelfProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final shelf = await _db.getShelf(widget.bookId);
    if (!mounted) return;

    final total = shelf?.totalPages ?? 0;
    final current = shelf?.currentPage ?? 0;
    final p = (total <= 0) ? 0.0 : (current / total).clamp(0.0, 1.0);

    setState(() {
      _progress = p;
      _label = '현재 진행도 ${(p * 100).round()}%';
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: widget.height,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 2),
        Text(_label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
