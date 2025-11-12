import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bookmark/features/search/domain/book.dart';
import 'package:bookmark/features/search/domain/search_repository.dart';

enum SearchStatus { idle, loading, success, error }

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._repo);

  final SearchRepository _repo;

  // UI 상태
  SearchStatus status = SearchStatus.idle;
  String? errorMessage;

  // 결과/페이지네이션
  final List<Book> _results = [];
  List<Book> get results => List.unmodifiable(_results);
  bool hasMore = false;
  int _page = 1;
  final int _pageSize = 20;

  // 중복 호출 방지
  Timer? _debounce;
  String _lastQuery = '';
  int _requestSeq = 0; // 요청 번호
  bool _loadingMore = false;

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query.trim());
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      // 초기화
      _results.clear();
      status = SearchStatus.idle;
      hasMore = false;
      _lastQuery = '';
      notifyListeners();
      return;
    }

    // 같은 쿼리로 다시 들어오면 무시 (첫 페이지 기준)
    if (_lastQuery == query && _page == 1 && status == SearchStatus.loading) {
      return;
    }

    _lastQuery = query;
    _page = 1;
    hasMore = false;
    _results.clear();
    status = SearchStatus.loading;
    errorMessage = null;
    notifyListeners();

    final mySeq = ++_requestSeq; // 이 요청의 시퀀스 번호

    try {
      final list = await _repo.searchBooks(query: query, page: _page, pageSize: _pageSize);

      // 오래된 응답 무시
      if (mySeq != _requestSeq) return;

      _results.addAll(list);
      hasMore = list.length == _pageSize;
      status = SearchStatus.success;

      if (kDebugMode && _results.isNotEmpty) {
        debugPrint('search first title = ${_results.first.title}');
      }
    } catch (e) {
      if (mySeq != _requestSeq) return;
      status = SearchStatus.error;
      errorMessage = '$e';
    } finally {
      if (mySeq == _requestSeq) notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_canLoadMore) return;
    _loadingMore = true;
    notifyListeners();

    final mySeq = ++_requestSeq;

    try {
      final next = _page + 1;
      final list = await _repo.searchBooks(query: _lastQuery, page: next, pageSize: _pageSize);

      if (mySeq != _requestSeq) return;

      _page = next;
      _results.addAll(list);
      hasMore = list.length == _pageSize;
    } catch (_) {
      // loadMore 실패는 무시
    } finally {
      if (mySeq == _requestSeq) {
        _loadingMore = false;
        notifyListeners();
      }
    }
  }

  bool get _canLoadMore =>
      status == SearchStatus.success &&
          !_loadingMore &&
          hasMore &&
          _lastQuery.isNotEmpty;
}
