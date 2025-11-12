import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/search/domain/book.dart';

extension LibraryItemX on LibraryItem {
  Book toBook() => Book(
    title: title,
    author: author,
    // LibraryItem.id == isbn13
    isbn13: id,
    coverUrl: coverUrl,
    pageCount: itemPage
  );
}
