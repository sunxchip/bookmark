import 'package:bookmark/features/library/domain/library_item.dart';

/// 임시 In-memory 저장소 (DataSource)
class LibraryLocalDataSource {

  final List<LibraryItem> _items = [];

  Future<List<LibraryItem>> getItems() async => List.unmodifiable(_items);

  Future<void> add(LibraryItem item) async {
    _items.removeWhere((e) => e.id == item.id);
    _items.insert(0, item);
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
  }


  Future<void> updatePageCount(String id, int itemPage) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(itemPage: itemPage);
    }
  }
}
