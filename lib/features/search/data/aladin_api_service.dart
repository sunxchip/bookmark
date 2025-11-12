import 'dart:convert';
import 'package:http/http.dart' as http;

/// 알라딘 OpenAPI 래퍼
/// - ItemSearch
/// - ItemLookUp (단건)
/// - itemLookupBatch (여러 ISBN13 순차 조회, 결과 리스트로 반환)
class AladinApiService {
  AladinApiService(this.ttbKey, {http.Client? client})
      : _client = client ?? http.Client();

  final String ttbKey;
  final http.Client _client;

  static const _base = 'https://www.aladin.co.kr/ttb/api';

  Future<Map<String, dynamic>> _get(
      String path, {
        required Map<String, String> params,
      }) async {
    final q = {
      'ttbkey': ttbKey,
      'output': 'js', // JSON
      'Version': '20131101',
      ...params,
    };
    final uri = Uri.parse('$_base$path').replace(queryParameters: q);
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Aladin API error: ${res.statusCode}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// 키워드 검색
  Future<Map<String, dynamic>> itemSearch({
    required String query,
    int start = 1,
    int maxResults = 20,
  }) {
    return _get('/ItemSearch.aspx', params: {
      'Query': query,
      'QueryType': 'Keyword',
      'SearchTarget': 'Book',
      'start': '$start',
      'MaxResults': '$maxResults',
    });
  }

  /// 단일 ISBN13 조회 (subInfo 포함)
  Future<Map<String, dynamic>> itemLookup({required String isbn13}) {
    return _get('/ItemLookUp.aspx', params: {
      'ItemIdType': 'ISBN13',
      'ItemId': isbn13,
      'OptResult': 'subInfo', // 서브 정보(예: itemPage) 포함
      'Cover': 'Large',
    });
  }

  /// 배치 조회: 알라딘 API가 공식 배치를 지원하지 않아
  /// 내부적으로 단건 조회를 반복 호출하여 결과 리스트로 합칩니다.
  /// 반환: 각 ISBN13의 첫 item 맵을 모은 List<Map<String,dynamic>>
  Future<List<Map<String, dynamic>>> itemLookupBatch(List<String> isbns) async {
    final results = <Map<String, dynamic>>[];
    for (final id in isbns.where((e) => e.trim().isNotEmpty)) {
      final data = await itemLookup(isbn13: id);
      final items = (data['item'] as List? ?? []).cast<Map<String, dynamic>>();
      if (items.isNotEmpty) results.add(items.first);
    }
    return results;
  }
}
