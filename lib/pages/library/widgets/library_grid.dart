import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/search/domain/book.dart';
import 'package:bookmark/features/reading/application/reading_view_model.dart';
import 'package:bookmark/features/reading/domain/reading_session.dart';
import 'package:bookmark/nav/tab_nav.dart';
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

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.item});
  final LibraryItem item;

  void _onTap(BuildContext context) {
    // LibraryItem -> Book 최소 변환 (필드명 프로젝트에 맞게 조정)
    final book = Book(
      title: item.title,
      author: '', // 있으면 채우기
      isbn13: '', // 있으면 채우기
      coverUrl: item.thumbnailUrl,
      pageCount: null,
    );

    OpenReadingSheet.show(
      context,
      book: book,
      onConfirm: () {
        // 1) 시트 닫기
        Navigator.of(context).pop();
        // 2) 세션 열기
        final session = ReadingSession.fromBook(book);
        context.read<ReadingViewModel>().open(session);
        // 3) 이어읽기 탭으로 이동
        TabNav.I.go(0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onTap(context),
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
                      item.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.menu_book_outlined, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.0, // TODO: item.progress 있으면 연결
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('현재 진행도 0%', style: theme.textTheme.labelSmall),
              ),
            ],
          );
        },
      ),
    );
  }
}
