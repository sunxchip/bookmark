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

  Future<void> add(LibraryItem item) async {
    await _repo.add(item);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    await load();
  }

  Future<void> addFromBook(Book b) async {
    final item = _mapBookToLibraryItem(b);

    if (_items.any((e) => e.id == item.id)) {
      await _repo.remove(item.id);
    }

    await _repo.add(item);
    await load();
    debugPrint("📚 '${item.title}' 내 서재에 담김! (총 ${_items.length}권)");
  }

  /// id: isbn13 있으면 사용, 없으면 title+timestamp
  /// coverUrl: Book.coverUrl
  /// isbn13Or10: isbn13 없으면 대체 키(가능하면 isbn10, 모를 땐 title)
  LibraryItem _mapBookToLibraryItem(Book b) {
    final id = (b.isbn13.isNotEmpty)
        ? b.isbn13
        : '${b.title}-${DateTime.now().millisecondsSinceEpoch}';

    final isbnForLookup =
    (b.isbn13.isNotEmpty) ? b.isbn13 : b.isbn13; // isbn10 필드가 없으면 임시로 title 사용해도 됨

    return LibraryItem(
      id: id,
      title: b.title,
      author: b.author,
      coverUrl: b.coverUrl,
      isbn13Or10: isbnForLookup,
      // pageCount: null
    );
  }
}
