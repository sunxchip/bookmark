import 'package:flutter/material.dart';
import 'package:bookmark/features/library/domain/library_item.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
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

            // 제목 2줄
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            // 진행도
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.0, // TODO: 실제 진행도
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
    );
  }
}
