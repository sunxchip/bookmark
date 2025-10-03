import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/search/application/search_view_model.dart';
import 'package:bookmark/features/search/domain/book.dart';
import 'add_to_library_sheet.dart';
import 'package:bookmark/common/widgets/top_toast.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    if (vm.status == SearchStatus.idle) {
      return const Center(child: Text('검색어를 입력해 보세요.'));
    }
    if (vm.status == SearchStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.status == SearchStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(vm.errorMessage ?? '오류가 발생했습니다.',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (vm.results.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          vm.loadMore();
        }
        return false;
      },
      child: ListView.separated(
        itemCount: vm.results.length + (vm.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          if (i >= vm.results.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final book = vm.results[i];
          return ListTile(
            leading: _cover(book.coverUrl),
            title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${book.author} · ${book.pageCount ?? 0}p'),
            onTap: () => _openAddToLibrarySheet(context, book),
          );
        },
      ),
    );
  }

  Widget _cover(String url) {
    if (url.isEmpty) return const Icon(Icons.book_outlined, size: 40);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(url, width: 48, height: 72, fit: BoxFit.cover),
    );
  }

  Future<void> _openAddToLibrarySheet(BuildContext context, Book book) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToLibrarySheet(book: book),
    );

    if (ok == true && context.mounted) {
      await showTopToast(context, message: '성공! 이제 서재에서 확인할 수 있어요 📚');
    }
  }
}
