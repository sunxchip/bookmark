import 'dart:async';
import 'package:flutter/material.dart';

// Library
import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_item_x.dart'; // .toBook()
import 'package:bookmark/features/library/domain/library_repository.dart';
import 'package:bookmark/features/library/application/page_count_resolver.dart';

// Reading
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';

// SQLite (진행률/총페이지 동기화)
import 'package:bookmark/data/repositories/sqlite_repository.dart';

/// 이어읽기 화면용 ViewModel
/// - 현재 세션 보유/전환
/// - 총 페이지 확보(알라딘 LookUp → repo 반영 → 폴백 입력)
/// - DB 변경(changes) 수신하여 진행률/총페이지 동기화
class ReadingViewModel extends ChangeNotifier {
  ReadingViewModel(
      this._libRepo,
      this._resolver, {
        SqliteRepository? sqlite,
      }) : _sqlite = sqlite ?? SqliteRepository.I {
    _sub = _sqlite.changes.listen((_) => _refreshCurrentFromDb());
  }

  // DI
  final LibraryRepository _libRepo;
  final PageCountResolver _resolver;
  final SqliteRepository _sqlite;

  // State
  StreamSubscription<void>? _sub;
  ReadingSession? _current;
  ReadingSession? get current => _current;
  bool get isEmpty => _current == null;
  double get progress => _current?.computedProgress ?? 0.0;

  // lifecycle
  Future<void> load() async {
    _current = null;
    notifyListeners();
  }

  void open(ReadingSession session) {
    _current = session;
    notifyListeners();
    _refreshCurrentFromDb(); // 열자마자 DB 최신값 한 번 보정
  }

  /// 서재 카드 → 이어읽기 전환 (DB shelf를 우선 적용)
  Future<void> openFromLibraryItem(LibraryItem item) async {
    // item.id == isbn13 (bookId)
    final shelf = await _sqlite.getShelf(item.id);

    var session = ReadingSession.fromBook(item.toBook());

    final last = shelf?.currentPage;
    if (last != null && last > 0) {
      session = session.withLastPage(last);
    }

    final total = shelf?.totalPages ?? item.itemPage;
    if (total != null && total > 0) {
      session = session.withTotalPages(total);
    }

    open(session);                 // notify 포함
    await _refreshCurrentFromDb(); // 즉시 동기화(안전)
  }

  Future<void> setCurrent(ReadingSession session) async => open(session);

  Future<void> clear() async {
    _current = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // -------- 총 페이지 확보(보장) --------
  Future<LibraryItem> ensurePageCount(
      BuildContext context,
      LibraryItem item,
      ) async {
    if ((item.itemPage ?? 0) > 0) {
      final total = item.itemPage!;
      if (_current != null && (_current!.totalPages ?? 0) <= 0) {
        _current = _current!.withTotalPages(total);
        notifyListeners();
      }
      return item;
    }

    // LookUp 시도(성공 시 repo 내부 갱신)
    await _resolver.resolveAndReplace(item);

    // 최신 리스트 재조회
    var list = await _libRepo.getItems();
    var updated = list.firstWhere((e) => e.id == item.id, orElse: () => item);

    if ((updated.itemPage ?? 0) > 0) {
      if (_current != null) {
        _current = _current!.withTotalPages(updated.itemPage!);
        notifyListeners();
      }
      return updated;
    }

    // 폴백: 직접 입력
    final input = await _askPageCount(context, updated.title);
    if (input != null && input > 0) {
      await _libRepo.updatePageCount(updated.id, input);
      list = await _libRepo.getItems();
      updated = list.firstWhere((e) => e.id == item.id, orElse: () => updated);

      if (_current != null) {
        _current = _current!.withTotalPages(input);
        notifyListeners();
      }
    }
    return updated;
  }

  // -------- 진행 페이지/진행률 갱신 --------
  Future<void> updateCurrentPage(int page) async {
    if (_current == null) return;
    _current = _current!.withLastPage(page);
    notifyListeners();
    await _sqlite.setCurrentPage(_current!.book.isbn13, page); // 내서재 카드와 즉시 동기화
  }

  double progressOf(LibraryItem item) {
    final cur = _current;
    if (cur == null) return 0.0;
    return (cur.book.isbn13 == item.id) ? cur.computedProgress : 0.0;
  }

  // -------- DB 최신값 반영 --------
  Future<void> _refreshCurrentFromDb() async {
    final cur = _current;
    if (cur == null) return;

    final shelf = await _sqlite.getShelf(cur.book.isbn13);
    if (shelf == null) return;

    final total = shelf.totalPages ?? cur.totalPages ?? 0;

    _current = cur
        .withLastPage(shelf.currentPage)
        .withTotalPages(total);

    notifyListeners();
  }

  // -------- 총 페이지 폴백 입력 --------
  Future<int?> _askPageCount(BuildContext context, String title) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('총 페이지 수 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '예: 264',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(context, v);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (!context.mounted) return result;
    return result;
  }
}
