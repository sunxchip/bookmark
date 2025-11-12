import 'dart:async';

import 'package:bookmark/features/search/domain/book.dart';
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/reading/domain/entities/reading_record.dart';

/// 간단한 In-memory 로컬 데이터소스
class ReadingLocalDataSource {
  final Map<String, ReadingSession> _store = {};
  final Map<String, StreamController<ReadingSession?>> _bus = {};

  String _sessionIdOf(Book b) => b.isbn13.isNotEmpty ? b.isbn13 : b.title;

  /// 없으면 생성, 있으면 기존 세션 반환
  Future<ReadingSession> startOrGet({
    required Book book,
    int? totalPages,
  }) async {
    final id = _sessionIdOf(book);
    var s = _store[id];
    if (s == null) {
      s = ReadingSession.fromBook(
        book,
        totalPagesOverride: totalPages,
      );
      _store[id] = s;
      _bus.putIfAbsent(id, () => StreamController<ReadingSession?>.broadcast());
      _bus[id]!.add(s);
    } else if (totalPages != null && (s.totalPages ?? 0) <= 0) {
      s = s.withTotalPages(totalPages);
      _store[id] = s;
      _bus[id]?.add(s);
    }
    return s;
    // 참고: 세션 식별은 외부에서 isbn13(or title)로 처리하면 됨
  }

  Future<void> addRecord({
    required String sessionId,
    required ReadingRecord record,
  }) async {
    final s = _store[sessionId];
    if (s == null) return;

    final newLast = record.page ?? s.lastPage;
    final updated = s.copyWith(
      lastPage: newLast,
      records: [record, ...s.records],
      updatedAt: DateTime.now(),
    );
    _store[sessionId] = updated;
    _bus.putIfAbsent(
      sessionId,
          () => StreamController<ReadingSession?>.broadcast(),
    ).add(updated);
  }

  Future<void> updateLastPage({
    required String sessionId,
    required int lastPage,
  }) async {
    final s = _store[sessionId];
    if (s == null) return;

    final updated = s.copyWith(
      lastPage: lastPage,
      updatedAt: DateTime.now(),
    );
    _store[sessionId] = updated;
    _bus.putIfAbsent(
      sessionId,
          () => StreamController<ReadingSession?>.broadcast(),
    ).add(updated);
  }

  /// 세션 스트림 구독
  Stream<ReadingSession?> watch(String sessionId) {
    _bus.putIfAbsent(sessionId, () => StreamController<ReadingSession?>.broadcast());
    // 현재 스냅샷 한 번 쏘고 이후 변경사항 스트림
    final controller = _bus[sessionId]!;
    // ignore: close_sinks (in-memory에서 앱 생애주기와 함께 간다)
    final seed = StreamController<ReadingSession?>();
    seed.add(_store[sessionId]);
    seed.addStream(controller.stream);
    return seed.stream;
  }
}
