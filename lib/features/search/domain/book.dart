class Book {
  final String title;
  final String author;
  final String isbn13;
  final String coverUrl; // 표지
  final int? pageCount;  // 쪽수
  const Book({
    required this.title,
    required this.author,
    required this.isbn13,
    required this.coverUrl,
    this.pageCount,
  });
}
