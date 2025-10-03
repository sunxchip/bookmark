import 'package:bookmark/features/search/domain/book.dart';

class BookDto {
  final String title;
  final String author;
  final String isbn13;
  final String cover;
  final String? itemPage; // 알라딘은 문자열로

  BookDto({
    required this.title,
    required this.author,
    required this.isbn13,
    required this.cover,
    this.itemPage,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) {
    return BookDto(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn13: json['isbn13'] ?? '',
      cover: json['cover'] ?? '',
      itemPage: json['itemPage']?.toString(),
    );
  }

  Book toDomain() => Book(
    title: title,
    author: author,
    isbn13: isbn13,
    coverUrl: cover,
    pageCount: itemPage == null ? null : int.tryParse(itemPage!),
  );
}
