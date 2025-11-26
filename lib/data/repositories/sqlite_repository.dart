import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:bookmark/data/models/models.dart';

/// 사용자별 SQLite 저장소
class SqliteRepository {
  SqliteRepository._();
  static final SqliteRepository I = SqliteRepository._();

  Database? _db;

  // 내서재/이어읽기 동기화를 위한 변경 스트림
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;

  /// 유저별 DB 오픈: app_<userId>.db
  Future<void> openForUser(String userId) async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'app_$userId.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE books(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT,
            thumbnail TEXT,
            pageCount INTEGER
          );
        ''');
        await db.execute('''
          CREATE TABLE shelf_items(
            bookId TEXT PRIMARY KEY,
            currentPage INTEGER NOT NULL DEFAULT 0,
            totalPages INTEGER,
            updatedAt INTEGER NOT NULL,
            FOREIGN KEY(bookId) REFERENCES books(id) ON DELETE CASCADE
          );
        ''');
        await db.execute('''
          CREATE TABLE reading_sessions(
            id TEXT PRIMARY KEY,
            bookId TEXT NOT NULL,
            duration INTEGER NOT NULL,
            reachedPage INTEGER NOT NULL,
            memo TEXT,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY(bookId) REFERENCES books(id) ON DELETE CASCADE
          );
        ''');
      },
    );
  }

  /// DB 닫기(로그아웃 시)
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Database get _requireDb {
    final d = _db;
    if (d == null) {
      throw StateError('SqliteRepository not opened. Call openForUser() first.');
    }
    return d;
  }

  // -------------------- Books / Shelf --------------------

  /// 책 upsert + shelf 행 보장
  Future<void> upsertBook(Book b) async {
    final d = _requireDb;
    await d.insert('books', b.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    final r = await d.query('shelf_items',
        where: 'bookId=?', whereArgs: [b.id], limit: 1);
    if (r.isEmpty) {
      await d.insert('shelf_items', {
        'bookId': b.id,
        'currentPage': 0,
        'totalPages': b.pageCount,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
    _changes.add(null);
  }

  Future<Book?> getBook(String id) async {
    final d = _requireDb;
    final rows = await d.query('books', where: 'id=?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Book.fromMap(rows.first);
  }

  Future<ShelfItem?> getShelf(String bookId) async {
    final d = _requireDb;
    final rows = await d.query('shelf_items',
        where: 'bookId=?', whereArgs: [bookId], limit: 1);
    if (rows.isEmpty) return null;
    return ShelfItem.fromMap(rows.first);
  }

  Future<List<ShelfItem>> allShelf() async {
    final d = _requireDb;
    final rows = await d.query('shelf_items', orderBy: 'updatedAt DESC');
    return rows.map(ShelfItem.fromMap).toList();
  }

  /// UPDATE 0건이면 INSERT로 보완(UPSERT)
  Future<void> setTotalPages(String bookId, int total) async {
    final d = _requireDb;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = await d.update(
      'shelf_items',
      {'totalPages': total, 'updatedAt': now},
      where: 'bookId=?',
      whereArgs: [bookId],
    );
    if (updated == 0) {
      await d.insert('shelf_items', {
        'bookId': bookId,
        'currentPage': 0,
        'totalPages': total,
        'updatedAt': now,
      });
    }

    await d.update('books', {'pageCount': total},
        where: 'id=?', whereArgs: [bookId]);

    _changes.add(null);
  }

  /// UPDATE 0건이면 INSERT로 보완(UPSERT)
  Future<void> setCurrentPage(String bookId, int page) async {
    final d = _requireDb;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updated = await d.update(
      'shelf_items',
      {'currentPage': page, 'updatedAt': now},
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

  // -------------------- Reading Sessions --------------------

  Future<ReadingSession> addSession(
      String bookId,
      Duration dur,
      int reachedPage, {
        String? memo,
      }) async {
    final d = _requireDb;
    final session = ReadingSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: bookId,
      duration: dur,
      reachedPage: reachedPage,
      createdAt: DateTime.now(),
      memo: memo,
    );
    await d.insert('reading_sessions', session.toMap());

    await setCurrentPage(bookId, reachedPage); // 진행/업데이트 동기화
    _changes.add(null);
    return session;
  }

  Future<void> deleteSession(String id) async {
    final d = _requireDb;
    await d.delete('reading_sessions', where: 'id=?', whereArgs: [id]);
    _changes.add(null);
  }

  Future<List<ReadingSession>> sessionsOf(String bookId) async {
    final d = _requireDb;
    final rows = await d.query(
      'reading_sessions',
      where: 'bookId=?',
      whereArgs: [bookId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(ReadingSession.fromMap).toList();
  }

  /// 내서재 카드용 DTO(책 + 선반 정보)
  Future<List<({Book book, ShelfItem shelf})>> libraryItems() async {
    final d = _requireDb;
    final rows = await d.rawQuery('''
      SELECT b.id, b.title, b.author, b.thumbnail, b.pageCount,
             s.currentPage, s.totalPages, s.updatedAt
      FROM books b
      LEFT JOIN shelf_items s ON s.bookId = b.id
      ORDER BY COALESCE(s.updatedAt, 0) DESC
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
        'currentPage': m['currentPage'] ?? 0,
        'totalPages': m['totalPages'],
        'updatedAt': m['updatedAt'] ?? 0,
      });
      return (book: b, shelf: s);
    }).toList();
  }
}
