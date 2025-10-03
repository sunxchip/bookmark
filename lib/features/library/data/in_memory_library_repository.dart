import 'package:bookmark/features/library/domain/library_repository.dart';
import 'package:bookmark/features/library/domain/library_item.dart';

class InMemoryLibraryRepository implements LibraryRepository {
  final List<LibraryItem> _items = [];

  @override
  Future<List<LibraryItem>> getItems() async => List.unmodifiable(_items);

  @override
  Future<void> add(LibraryItem item) async {
    _items.removeWhere((e) => e.id == item.id);
    _items.insert(0, item);
  }

  @override
  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
