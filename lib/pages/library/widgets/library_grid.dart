import 'package:flutter/material.dart';
import 'package:bookmark/features/library/domain/library_item.dart';

class LibraryGrid extends StatelessWidget {
  const LibraryGrid({super.key, required this.items});
  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    // TODO: 표지/제목/저자 카드 UI
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => const Placeholder(),
    );
  }
}
