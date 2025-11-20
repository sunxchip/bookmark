import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService I = DatabaseService._();
  DatabaseService._();

  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'leafmark.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (d, v) async {
        await d.execute('''
          CREATE TABLE books(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT,
            thumbnail TEXT,
            pageCount INTEGER
          )
        ''');

        await d.execute('''
          CREATE TABLE shelf_items(
            bookId TEXT PRIMARY KEY,
            currentPage INTEGER NOT NULL,
            totalPages INTEGER,
            updatedAt INTEGER NOT NULL
          )
        ''');

        await d.execute('''
          CREATE TABLE reading_sessions(
            id TEXT PRIMARY KEY,
            bookId TEXT NOT NULL,
            durationSeconds INTEGER NOT NULL,
            reachedPage INTEGER NOT NULL,
            createdAt INTEGER NOT NULL,
            memo TEXT
          )
        ''');

        await d.execute(
          'CREATE INDEX idx_sessions_book ON reading_sessions(bookId)',
        );
      },
      onUpgrade: (d, oldV, newV) async {
        if (oldV < 2) {
          await d.execute(
            'ALTER TABLE reading_sessions ADD COLUMN memo TEXT',
          );
        }
      },
    );
  }
}
