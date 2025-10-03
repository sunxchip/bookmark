import 'package:bookmark/features/search/domain/search_repository.dart';
import 'package:bookmark/features/search/domain/book.dart';
import 'aladin_api_service.dart';
import 'book_dto.dart';

class SearchRepositoryImpl implements SearchRepository {
  final AladinApiService api;
  SearchRepositoryImpl(this.api);

  @override
  Future<List<Book>> searchBooks({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final data = await api.itemSearch(
      query: query,
      start: page,
      maxResults: pageSize,
    );
    final items = (data['item'] as List? ?? []);
    return items.map((e) => BookDto.fromJson(e).toDomain()).toList();
  }
}
