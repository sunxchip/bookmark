import 'package:bookmark/features/reading/domain/entities/reading_record.dart';
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/search/domain/book.dart';

abstract class ReadingRepository {
  Future<ReadingSession> startOrGetSession({
    required Book book,
    int? totalPages,   // 알라딘/수동 입력값
  });

  Future<void> addRecord({
    required String sessionId,
    required ReadingRecord record,
  });

  /// 진행 페이지 갱신(기록과 별도 수동 입력을 지원하고 싶을 때)
  Future<void> updateLastPage({
    required String sessionId,
    required int lastPage,
  });

  /// 세션 스트림(진행률/기록 변경 시 UI 자동 반영)
  Stream<ReadingSession?> watchSession(String sessionId);
}
