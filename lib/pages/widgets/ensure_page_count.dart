import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/reading/application/reading_view_model.dart';

/// 이어읽기 화면에서 총 페이지를 보장한 뒤 child를 그려주는 헬퍼.
/// 처음 한 번만 LookUp을 시도하고, 실패 시엔 사용자 입력을 받아 저장한다.
class EnsurePageCount extends StatefulWidget {
  const EnsurePageCount({
    super.key,
    required this.item,
    required this.builder,
  });

  final LibraryItem item;
  final Widget Function(BuildContext context, LibraryItem ensured) builder;

  @override
  State<EnsurePageCount> createState() => _EnsurePageCountState();
}

class _EnsurePageCountState extends State<EnsurePageCount> {
  LibraryItem? _ensured;

  @override
  void initState() {
    super.initState();
    _ensure();
  }

  Future<void> _ensure() async {
    final vm = context.read<ReadingViewModel>();
    final ensured = await vm.ensurePageCount(context, widget.item);
    if (mounted) setState(() => _ensured = ensured);
  }

  @override
  Widget build(BuildContext context) {
    final item = _ensured ?? widget.item;
    return widget.builder(context, item);
  }
}
