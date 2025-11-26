import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:bookmark/data/db/database_service.dart';
import 'package:bookmark/data/models/models.dart';

class SqliteRepository {
  static final SqliteRepository I = SqliteRepository._();
  SqliteRepository._();

  // 브로드캐스트(내서재/이어읽기 동기화)
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;

  Future<void> upsertBook(Book b) async {
    final d = await DatabaseService.I.db;
    await d.insert('books', b.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    // 서재 엔트리 없으면 생성
    final existing = await d.query(
      'shelf_items',
      where: 'bookId=?',
      whereArgs: [b.id],
      limit: 1,
    );
    if (existing.isEmpty) {
      await d.insert(
        'shelf_items',
        ShelfItem(
          bookId: b.id,
          currentPage: 0,
          totalPages: b.pageCount,
          updatedAt: DateTime.now(),
        ).toMap(),
      );
      _changes.add(null);
    }
  }

  Future<Book?> getBook(String id) async {
    final d = await DatabaseService.I.db;
    final rows =
    await d.query('books', where: 'id=?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Book.fromMap(rows.first);
  }

  Future<ShelfItem?> getShelf(String bookId) async {
    final d = await DatabaseService.I.db;
    final rows = await d.query(
      'shelf_items',
      where: 'bookId=?',
      whereArgs: [bookId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ShelfItem.fromMap(rows.first);
  }

  Future<List<ShelfItem>> allShelf() async {
    final d = await DatabaseService.I.db;
    final rows = await d.query('shelf_items', orderBy: 'updatedAt DESC');
    return rows.map(ShelfItem.fromMap).toList();
  }

  // ⬇⬇⬇ 수정 포인트 1: UPDATE 0건이면 INSERT로 보완(UPSERT) ⬇⬇⬇
  Future<void> setTotalPages(String bookId, int total) async {
    final d = await DatabaseService.I.db;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = await d.update(
      'shelf_items',
      {
        'totalPages': total,
        'updatedAt': now,
      },
      where: 'bookId=?',
      whereArgs: [bookId],
    );

    if (updated == 0) {
      // shelf 행이 아직 없었던 경우 최초 생성
      await d.insert('shelf_items', {
        'bookId': bookId,
        'currentPage': 0,
        'totalPages': total,
        'updatedAt': now,
      });
    }

    // books.pageCount 동기
    await d.update('books', {'pageCount': total},
        where: 'id=?', whereArgs: [bookId]);

    _changes.add(null);
  }

  //UPDATE 0건이면 INSERT로 보완(UPSERT)
  Future<void> setCurrentPage(String bookId, int page) async {
    final d = await DatabaseService.I.db;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = await d.update(
      'shelf_items',
      {
        'currentPage': page,
        'updatedAt': now,
      },
      where: 'bookId=?',
      whereArgs: [bookId],
    );

    if (updated == 0) {
      await d.insert('shelf_items', {
        'bookId': bookId,
        'currentPage': page,
        'totalPages': null,
        'updatedAt': now,
      });
    }

    _changes.add(null);
  }

  /// 세션 추가(메모 추가) + 생성된 세션 반환
  Future<ReadingSession> addSession(
      String bookId,
      Duration dur,
      int reachedPage, {
        String? memo,
      }) async {
    final d = await DatabaseService.I.db;
    final session = ReadingSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: bookId,
      duration: dur,
      reachedPage: reachedPage,
      createdAt: DateTime.now(),
      memo: memo,
    );
    await d.insert('reading_sessions', session.toMap());

    await setCurrentPage(bookId, reachedPage); // 진행률 동기화
    _changes.add(null);

    return session;
  }

  Future<void> deleteSession(String id) async {
    final d = await DatabaseService.I.db;
    await d.delete('reading_sessions', where: 'id=?', whereArgs: [id]);
    _changes.add(null);
  }

  Future<List<ReadingSession>> sessionsOf(String bookId) async {
    final d = await DatabaseService.I.db;
    final rows = await d.query(
      'reading_sessions',
      where: 'bookId=?',
      whereArgs: [bookId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(ReadingSession.fromMap).toList();
  }

  /// 내서재 목록(책 + 진행 정보 DTO)
  Future<List<({Book book, ShelfItem shelf})>> libraryItems() async {
    final d = await DatabaseService.I.db;
    final rows = await d.rawQuery('''
      SELECT b.*, s.currentPage, s.totalPages, s.updatedAt
      FROM books b
      JOIN shelf_items s ON s.bookId = b.id
      ORDER BY s.updatedAt DESC
    ''');
    return rows.map((m) {
      final b = Book.fromMap({
        'id': m['id'],
        'title': m['title'],
        'author': m['author'],
        'thumbnail': m['thumbnail'],
        'pageCount': m['pageCount'],
      });
      final s = ShelfItem.fromMap({
        'bookId': m['id'],
        'currentPage': m['currentPage'],
        'totalPages': m['totalPages'],
        'updatedAt': m['updatedAt'],
      });
      return (book: b, shelf: s);
    }).toList();
  }
}
