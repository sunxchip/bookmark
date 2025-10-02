import 'package:bookmark/features/library/domain/library_item.dart';

/// 임시 In-memory 저장소
class LibraryLocalDataSource {
  final List<LibraryItem> _items = [];

  Future<List<LibraryItem>> getItems() async => List.unmodifiable(_items);

  Future<void> add(LibraryItem item) async {
    _items.add(item);
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
