import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_repository.dart';
import 'package:bookmark/features/search/data/aladin_api_service.dart';

import 'package:bookmark/features/library/domain/library_item_x.dart';

class PageCountResolver {
  PageCountResolver(this.api, this.repo);

  final AladinApiService api;
  final LibraryRepository repo;

  /// item.pageCount 가 없을 때 알라딘에서 찾아 repo.updatePageCount 로 반영
  Future<void> resolveAndReplace(LibraryItem item) async {
    // 확장에서 제공하는 isbn13 (13자리 숫자가 아니면 빈 문자열을 리턴하도록 구현되어 있음)
    final isbn = item.id;
    if (isbn.isEmpty) return;

    int? page;

    try {
      // 우리가 추가한 배치 메서드(내부적으로 단건 조회 반복)
      final batch = await api.itemLookupBatch([isbn]);
      if (batch.isNotEmpty) {
        page = _extractPage(batch.first);
      }
    } catch (_) {
      // 폴백: 단건 조회
      final data = await api.itemLookup(isbn13: isbn);
      final items = (data['item'] as List? ?? []).cast<Map<String, dynamic>>();
      if (items.isNotEmpty) {
        page = _extractPage(items.first);
      }
    }

    if (page != null && page > 0) {
      await repo.updatePageCount(item.id, page);
    }
  }

  /// subInfo.itemPage 또는 itemPage (int 또는 String)에서 페이지 파싱
  int? _extractPage(Map<String, dynamic> e) {
    final sub = e['subInfo'] as Map<String, dynamic>?;
    dynamic v = sub != null ? sub['itemPage'] : null;
    v ??= e['itemPage'];

    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}
