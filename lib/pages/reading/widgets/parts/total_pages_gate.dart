import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookmark/features/reading/application/reading_detail_controller.dart';
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';

/// 같은 앱 세션 동안 책별로 총 페이지 입력 팝업을 최대 1번만 띄움.
/// 또한, 다른 책으로 전환되면 컨트롤러를 재-init 해서 동기화 보장.
final Set<String> _askedOnce = <String>{};

class TotalPagesGate extends StatefulWidget {
  final Widget child;
  final Future<void> Function(int pages) onConfirmTotalPages;

  const TotalPagesGate({
    super.key,
    required this.child,
    required this.onConfirmTotalPages,
  });

  @override
  State<TotalPagesGate> createState() => _TotalPagesGateState();
}

class _TotalPagesGateState extends State<TotalPagesGate> {
  bool _asking = false;
  String? _lastBookId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAsk();
  }

  @override
  void didUpdateWidget(covariant TotalPagesGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAsk();
  }

  Future<void> _maybeAsk() async {
    if (!mounted || _asking) return;
    final c = context.read<ReadingDetailController>();
    final bookId = c.isbn13;
    final total = c.totalPages ?? 0;

    if (total > 0) return;
    if (_askedOnce.contains(bookId)) return;
    if (_lastBookId == bookId) return;

    _asking = true;
    _lastBookId = bookId;

    final n = await _askDialog(context, initial: c.totalPages);
    _asking = false;
    if (!mounted) return;

    if (n != null && n > 0) {
      await widget.onConfirmTotalPages(n);
    }
    _askedOnce.add(bookId); // 취소해도 중복 방지
  }

  Future<int?> _askDialog(BuildContext context, {int? initial}) async {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              Navigator.pop(context, (n != null && n > 0) ? n : null);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
