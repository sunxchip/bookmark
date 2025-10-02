import 'package:flutter/foundation.dart';
import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_repository.dart';

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
}
