import 'package:bookmark/features/search/domain/book.dart';

class ReadingSession {
  final Book book;
  /// 0.0 ~ 1.0 (없으면 0으로 시작)
  final double progress;
  /// 마지막 읽은 페이지 (1-based, 없으면 null)
  final int? lastPage;

  const ReadingSession({
    required this.book,
    this.progress = 0.0,
    this.lastPage,
  });

  factory ReadingSession.fromBook(Book book) =>
      ReadingSession(book: book, progress: 0.0);

  int? get totalPages => book.pageCount;
}
