import 'package:bookmark/features/search/domain/book.dart';

class BookDto {
  final String title;
  final String author;
  final String cover;
  final String isbn13;
  final int? itemPage;

  BookDto({
    required this.title,
    required this.author,
    required this.cover,
    required this.isbn13,
    required this.itemPage,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) {
    final dynamic rawItemPage =
        json['itemPage'] ?? (json['subInfo'] != null ? json['subInfo']['itemPage'] : null);

    int? parsedPage;
    if (rawItemPage is int) {
      parsedPage = rawItemPage;
    } else if (rawItemPage is String) {
      parsedPage = int.tryParse(rawItemPage);
    }

    return BookDto(
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      cover: (json['cover'] ?? '').toString(),
      isbn13: (json['isbn13'] ?? '').toString(),
      itemPage: parsedPage,
    );
  }

  Book toDomain() => Book(
    title: title,
    author: author,
    coverUrl: cover,
    isbn13: isbn13,
    pageCount: itemPage,
  );
}
