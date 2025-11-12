class LibraryItem {
  final String id;           // 고유키(ISBN13 우선, 없으면 ISBN10/제목 등)
  final String title;
  final String author;
  final String coverUrl;
  final String isbn13Or10;   // LookUp용 키(13 없으면 10)
  final int? itemPage;

  const LibraryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.isbn13Or10,
    this.itemPage,
  });

  LibraryItem copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? isbn13Or10,
    int? itemPage,
    bool clearPageCount = false,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      isbn13Or10: isbn13Or10 ?? this.isbn13Or10,
      itemPage: clearPageCount ? null : (itemPage ?? this.itemPage),
    );
  }
}
