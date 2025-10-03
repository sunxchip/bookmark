import 'dart:convert';
import 'package:http/http.dart' as http;

class AladinApiService {
  final String ttbKey;
  AladinApiService(this.ttbKey);

  Future<Map<String, dynamic>> itemSearch({
    required String query,
    int start = 1,
    int maxResults = 20,
  }) async {
    final uri = Uri.parse('https://www.aladin.co.kr/ttb/api/ItemSearch.aspx')
        .replace(queryParameters: {
      'ttbkey': ttbKey,
      'Query': query,
      'QueryType': 'Keyword',   // Title
      'SearchTarget': 'Book',
      'MaxResults': '$maxResults',
      'start': '$start',
      'Output': 'js',           // JSON
      'Version': '20131101',
    });

    final r = await http.get(uri);
    if (r.statusCode != 200) {
      throw Exception('Aladin API error: ${r.statusCode}');
    }
    // 한글 깨짐 방지
    final data = json.decode(utf8.decode(r.bodyBytes));
    return data as Map<String, dynamic>;
  }
}
