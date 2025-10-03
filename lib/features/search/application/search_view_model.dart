import 'package:flutter/foundation.dart';
import '../domain/book.dart';
import '../domain/search_repository.dart';

enum SearchStatus { idle, loading, success, error }

class SearchViewModel extends ChangeNotifier {
  final SearchRepository repo;
  SearchViewModel(this.repo);

  SearchStatus status = SearchStatus.idle;
  String query = '';
  List<Book> results = [];
  String? errorMessage;
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;

  Future<void> search(String q) async {
    query = q.trim();
    if (query.isEmpty) return;
    status = SearchStatus.loading;
    notifyListeners();
    _page = 1;
    _hasMore = true;

    try {
      final items = await repo.searchBooks(query: query, page: _page, pageSize: _pageSize);
      results = items;
      _hasMore = items.length == _pageSize;
      status = SearchStatus.success;
    } catch (e) {
      status = SearchStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || status != SearchStatus.success) return;
    _isLoadingMore = true;
    _page += 1;
    try {
      final items = await repo.searchBooks(query: query, page: _page, pageSize: _pageSize);
      results = [...results, ...items];
      _hasMore = items.length == _pageSize;
    } catch (_) {
      // 무시하고 더 이상 불러오지 않음
      _hasMore = false;
    }
    _isLoadingMore = false;
    notifyListeners();
  }
}
