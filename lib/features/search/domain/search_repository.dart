import 'package:bookmark/features/search/domain/book.dart';

abstract class SearchRepository {
  /// page는 1부터, pageSize 기본 20
  Future<List<Book>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}
