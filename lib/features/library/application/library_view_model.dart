import 'package:flutter/foundation.dart';
import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_repository.dart';
import 'package:bookmark/features/search/domain/book.dart';

class LibraryViewModel extends ChangeNotifier {
  final LibraryRepository _repo;
  LibraryViewModel(this._repo);

  List<LibraryItem> _items = [];
  List<LibraryItem> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  Object? _error;
  Object? get error => _error;

  /// 내 서재 목록 불러오기
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.getItems();
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 기존 LibraryItem 직접 추가
  Future<void> add(LibraryItem item) async {
    await _repo.add(item);
    await load(); // 저장 후 최신 상태 재로드
  }

  /// 아이템 제거
  Future<void> remove(String id) async {
    await _repo.remove(id);
    await load();
  }

  /// 검색 결과(Book)를 내 서재에 담기
  Future<void> addFromBook(Book b) async {
    final item = _mapBookToLibraryItem(b);

    // 중복 방지(동일 id가 있으면 먼저 제거)
    if (_items.any((e) => e.id == item.id)) {
      await _repo.remove(item.id);
    }

    await _repo.add(item);
    await load();
    debugPrint("📚 '${item.title}' 내 서재에 담김! (총 ${_items.length}권)");
  }

  /// 매핑 규칙:
  /// - id: isbn13이 있으면 사용, 없으면 title+timestamp
  /// - thumbnailUrl: Book.coverUrl 그대로
  LibraryItem _mapBookToLibraryItem(Book b) {
    final id = (b.isbn13.isNotEmpty)
        ? b.isbn13
        : '${b.title}-${DateTime.now().millisecondsSinceEpoch}';

    return LibraryItem(
      id: id,
      title: b.title,
      author: b.author,
      thumbnailUrl: b.coverUrl,
    );
  }
}
