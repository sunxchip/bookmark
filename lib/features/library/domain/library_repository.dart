import 'library_item.dart';

abstract class LibraryRepository {
  Future<List<LibraryItem>> getItems();
  Future<void> add(LibraryItem item);
  Future<void> remove(String id);
  Future<void> updatePageCount(String id, int pageCount);

}
