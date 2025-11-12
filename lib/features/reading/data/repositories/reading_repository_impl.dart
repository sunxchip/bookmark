import 'package:bookmark/features/reading/domain/repositories/reading_repository.dart';
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/reading/domain/entities/reading_record.dart';
import 'package:bookmark/features/search/domain/book.dart';
import 'package:bookmark/features/reading/data/datasources/reading_local_ds.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final ReadingLocalDataSource local;
  ReadingRepositoryImpl(this.local);

  @override
  Future<void> addRecord({
    required String sessionId,
    required ReadingRecord record,
  }) =>
      local.addRecord(sessionId: sessionId, record: record);

  @override
  Future<ReadingSession> startOrGetSession({
    required Book book,
    int? totalPages,
  }) =>
      local.startOrGet(book: book, totalPages: totalPages);

  @override
  Future<void> updateLastPage({
    required String sessionId,
    required int lastPage,
  }) =>
      local.updateLastPage(sessionId: sessionId, lastPage: lastPage);

  @override
  Stream<ReadingSession?> watchSession(String sessionId) =>
      local.watch(sessionId);
}
