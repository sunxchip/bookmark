import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_repository.dart';
import 'library_local.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource local;
  LibraryRepositoryImpl(this.local);

  @override
  Future<List<LibraryItem>> getItems() => local.getItems();

  @override
  Future<void> add(LibraryItem item) => local.add(item);

  @override
  Future<void> remove(String id) => local.remove(id);

  @override
  Future<void> updatePageCount(String id, int pageCount) =>
      local.updatePageCount(id, pageCount);
}
