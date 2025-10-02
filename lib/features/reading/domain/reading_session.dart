class ReadingSession {
  final String bookId;
  final String title;
  final String author;
  final String thumbnailUrl;
  final int currentPage;
  final int totalPages;

  const ReadingSession({
    required this.bookId,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.currentPage,
    required this.totalPages,
  });

  double get progress =>
      totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0, 1);
}
