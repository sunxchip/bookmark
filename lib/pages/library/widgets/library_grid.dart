import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_item_x.dart'; // toBook()
import 'package:bookmark/features/reading/application/reading_view_model.dart';
import 'package:bookmark/nav/tab_nav.dart';
import 'package:bookmark/pages/library/widgets/shelf_progress.dart';
import 'package:bookmark/pages/reading/widgets/open_reading_sheet.dart';

class LibraryGrid extends StatelessWidget {
  const LibraryGrid({super.key, required this.items});
  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.52,
      ),
      itemBuilder: (_, i) => _LibraryCard(item: items[i]),
    );
  }
}

class _LibraryCard extends StatefulWidget {
  const _LibraryCard({required this.item});
  final LibraryItem item;

  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard> {
  bool _busy = false;

  Future<void> _onTap(BuildContext context) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await OpenReadingSheet.show(
        context,
        book: widget.item.toBook(),
        onConfirm: () async {
          final reading = context.read<ReadingViewModel>();

          // 1) 책별 세션 전환(진행/총페이지 DB 반영)
          await reading.openFromLibraryItem(widget.item);

          // 2) 총 페이지 확보(알라딘 조회/사용자 입력 폴백)
          await reading.ensurePageCount(context, widget.item);

          // 3) 시트 닫고 → 이어읽기 탭 이동
          final nav = Navigator.of(context, rootNavigator: true);
          await nav.maybePop(); // 시트가 열려있다면 닫힘
          if (!mounted) return;
          TabNav.I.go(0);
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _busy ? null : () => _onTap(context),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final coverH = constraints.maxHeight * 0.62;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: coverH,
                      child: AspectRatio(
                        aspectRatio: 0.66,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.item.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              // Flutter 3.22+ deprecations 대응
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.menu_book_outlined, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // 내 서재 카드용 진행도
                    ShelfProgress(bookId: widget.item.id),
                  ],
                );
              },
            ),
          ),
        ),
        if (_busy)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  // withOpacity 경고 회피: withAlpha 사용
                  color: Colors.black.withAlpha((0.18 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
