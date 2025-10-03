import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/search/domain/book.dart';
import 'package:bookmark/features/library/application/library_view_model.dart';

class AddToLibrarySheet extends StatelessWidget {
  const AddToLibrarySheet({super.key, required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.45, minChildSize: 0.3, maxChildSize: 0.9,
      builder: (ctx, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _handleBar(theme),
                Text('내 서재에 담기 ›', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _bookRow(theme),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final ok = await _addBookToLibrary(context, book);
                    if (context.mounted) Navigator.of(context).pop(ok);
                  },
                  child: const Text('계속하기'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('뒤로가기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _handleBar(ThemeData theme) => Center(
    child: Container(
      width: 40, height: 5,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  Widget _bookRow(ThemeData theme) => Row(
    children: [
      _thumb(book.coverUrl),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          '“${book.title}” 을(를)\n내 서재에 담을까요?',
          style: theme.textTheme.titleMedium,
          maxLines: 3, overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _thumb(String url) {
    if (url.isEmpty) {
      return Container(
        width: 64, height: 90, alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: Colors.grey.withOpacity(0.4)),
        ),
        child: const Icon(Icons.book_outlined),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(url, width: 64, height: 90, fit: BoxFit.cover),
    );
  }

  Future<bool> _addBookToLibrary(BuildContext context, Book book) async {
    try {
      final libVM = context.read<LibraryViewModel>();
      await libVM.addFromBook(book);
      return true;
    } catch (_) {
      return false;
    }
  }
}
