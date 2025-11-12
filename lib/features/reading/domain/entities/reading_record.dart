class ReadingRecord {
  final DateTime when;
  final Duration duration;
  final int? page;      // 기록 시점의 마지막 읽은 페이지
  final String? memo;   // 메모

  const ReadingRecord({
    required this.when,
    required this.duration,
    this.page,
    this.memo,
  });
}
