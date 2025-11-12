import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/reading/domain/repositories/reading_repository.dart';
import 'package:bookmark/features/search/domain/book.dart';

class StartOrGetSession {
  final ReadingRepository repo;
  StartOrGetSession(this.repo);

  Future<ReadingSession> call({
    required Book book,
    int? totalPages,
  }) {
    return repo.startOrGetSession(book: book, totalPages: totalPages);
  }
}
