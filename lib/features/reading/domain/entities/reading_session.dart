import 'package:bookmark/features/search/domain/book.dart';
import 'reading_record.dart';

/// 이어읽기 세션 도메인 엔티티
class ReadingSession {
  final Book book;

  /// 0.0~1.0 (lastPage/totalPages가 없을 때만 사용)
  final double progress;

  /// 마지막 읽은 페이지(1-based)
  final int? lastPage;

  /// 책에서 내려온 pageCount 대신 강제로 지정한 총 페이지 (사용자 입력 등)
  final int? totalPagesOverride;

  /// 최근 갱신 시각(옵션)
  final DateTime? updatedAt;

  /// 독서 기록(옵션)
  final List<ReadingRecord> records;

  const ReadingSession({
    required this.book,
    this.progress = 0.0,
    this.lastPage,
    this.totalPagesOverride,
    this.updatedAt,
    this.records = const [],
  });

  /// 검색/서재의 Book으로 새 세션 시작
  factory ReadingSession.fromBook(
      Book book, {
        int? totalPagesOverride,
      }) =>
      ReadingSession(book: book, totalPagesOverride: totalPagesOverride);

  /// 총 페이지(override > book.pageCount 순)
  int? get totalPages => totalPagesOverride ?? book.pageCount;

  /// lastPage & totalPages가 있으면 그것으로 진행률 계산,
  /// 없으면 기존 progress 사용
  double get computedProgress {
    final tp = totalPages;
    final lp = lastPage;
    if (tp != null && tp > 0 && lp != null && lp > 0) {
      final v = lp / tp;
      if (v < 0) return 0;
      if (v > 1) return 1;
      return v;
    }
    return progress.clamp(0.0, 1.0);
  }

  /// 총 페이지만 교체
  ReadingSession withTotalPages(int total) => copyWith(
    totalPagesOverride: total,
    updatedAt: DateTime.now(),
  );

  /// 마지막 페이지 변경(진행률 자동 반영)
  ReadingSession withLastPage(int page) => copyWith(
    lastPage: page,
    updatedAt: DateTime.now(),
  );

  ReadingSession copyWith({
    Book? book,
    double? progress,
    int? lastPage,
    int? totalPagesOverride,
    DateTime? updatedAt,
    List<ReadingRecord>? records,
  }) {
    return ReadingSession(
      book: book ?? this.book,
      progress: progress ?? this.progress,
      lastPage: lastPage ?? this.lastPage,
      totalPagesOverride: totalPagesOverride ?? this.totalPagesOverride,
      updatedAt: updatedAt ?? this.updatedAt,
      records: records ?? this.records,
    );
  }
}
