// DB (로컬 저장용)

class Book {
  final String id;
  final String title;
  final String? author;
  final String? thumbnailUrl;
  final int? pageCount;

  const Book({
    required this.id,
    required this.title,
    this.author,
    this.thumbnailUrl,
    this.pageCount,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'thumbnail': thumbnailUrl,
    'pageCount': pageCount,
  };

  factory Book.fromMap(Map<String, Object?> m) => Book(
    id: m['id'] as String,
    title: m['title'] as String,
    author: m['author'] as String?,
    thumbnailUrl: m['thumbnail'] as String?,
    pageCount: m['pageCount'] as int?,
  );

  Book copyWith({int? pageCount}) => Book(
    id: id,
    title: title,
    author: author,
    thumbnailUrl: thumbnailUrl,
    pageCount: pageCount ?? this.pageCount,
  );
}

class ShelfItem {
  final String bookId;
  final int currentPage;
  final int? totalPages;
  final DateTime updatedAt;

  const ShelfItem({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.updatedAt,
  });

  int get progressPercent {
    if (totalPages == null || totalPages == 0) return 0;
    final p = (currentPage / (totalPages!.clamp(1, 100000))) * 100;
    return p.clamp(0, 100).round();
    // UI 프로그레스바는 currentPage/totalPages로 계산
  }

  Map<String, Object?> toMap() => {
    'bookId': bookId,
    'currentPage': currentPage,
    'totalPages': totalPages,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory ShelfItem.fromMap(Map<String, Object?> m) => ShelfItem(
    bookId: m['bookId'] as String,
    currentPage: (m['currentPage'] as int?) ?? 0,
    totalPages: m['totalPages'] as int?,
    updatedAt:
    DateTime.fromMillisecondsSinceEpoch((m['updatedAt'] as int?) ?? 0),
  );

  ShelfItem copyWith({int? currentPage, int? totalPages}) => ShelfItem(
    bookId: bookId,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    updatedAt: DateTime.now(),
  );
}

class ReadingSession {
  final String id;
  final String bookId;
  final Duration duration;
  final int reachedPage;
  final DateTime createdAt;
  final String? memo;

  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.duration,
    required this.reachedPage,
    required this.createdAt,
    this.memo,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'bookId': bookId,
    'durationSeconds': duration.inSeconds,
    'reachedPage': reachedPage,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'memo': memo,
  };

  factory ReadingSession.fromMap(Map<String, Object?> m) => ReadingSession(
    id: m['id'] as String,
    bookId: m['bookId'] as String,
    duration: Duration(seconds: (m['durationSeconds'] as int?) ?? 0),
    reachedPage: (m['reachedPage'] as int?) ?? 0,
    createdAt:
    DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as int?) ?? 0),
    memo: m['memo'] as String?,
  );
}
