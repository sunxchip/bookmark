import 'dart:convert';

class BookMetadataService {
  int parseTotalPagesFromResponse(String jsonStr) {
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      // 알라딘: { item: [ { subInfo: { itemPage: 558 } } ] }
      if (map['item'] is List && (map['item'] as List).isNotEmpty) {
        final first = (map['item'] as List).first as Map<String, dynamic>;
        final sub = first['subInfo'] as Map<String, dynamic>?;
        final page = sub?['itemPage'];
        if (page is int && page > 0) return page;
      }
      // (백업) 혹시 다른 필드
      if (map['items'] is List && (map['items'] as List).isNotEmpty) {
        final vi = ((map['items'] as List).first as Map<String, dynamic>)['volumeInfo'] as Map<String, dynamic>?;
        final pc = vi?['pageCount'];
        if (pc is int && pc > 0) return pc;
      }
    } catch (_) {}
    return 0;
  }
}
