import 'package:flutter/foundation.dart';
import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/data/repositories/sqlite_repository.dart';

/// UI에 표시할 로그 뷰모델
class ReadingLogVm {
  final String id;             // DB 세션 id
  final DateTime createdAt;
  final Duration duration;
  final int reachedPage;
  final String? memo;

  const ReadingLogVm(
      this.id,
      this.createdAt,
      this.duration,
      this.reachedPage, {
        this.memo,
      });
}

class ReadingDetailController extends ChangeNotifier {
  final _repo = SqliteRepository.I;

  late ReadingSession _base; // 진입 스냅샷
  int? _totalPages;
  int _currentPage = 0;
  final List<ReadingLogVm> _logs = [];

  // 화면 최초 진입 시 호출
  Future<void> init(ReadingSession session) async {
    _base = session;
    _currentPage = session.lastPage ?? 0;
    _totalPages = session.totalPages ?? session.book.pageCount;

    // 기존 저장된 로그 불러오기
    await _refreshLogs();
    notifyListeners();
  }

  // == getters ==
  String get isbn13 => _base.book.isbn13;
  String get title  => _base.book.title;
  String get author => _base.book.author;
  String get cover  => _base.book.coverUrl;

  int?  get totalPages => _totalPages;
  int   get currentPage => _currentPage;

  List<ReadingLogVm> get logs => List.unmodifiable(_logs);

  double get progress {
    final t = _totalPages ?? 0;
    if (t <= 0) return 0;
    return (_currentPage / t).clamp(0, 1);
  }

  // == commands ==
  // 총 페이지 설정(사용자 입력/파싱 결과)
  Future<void> setTotalPages(int pages) async {
    if (pages <= 0) return;
    await _repo.setTotalPages(isbn13, pages);
    _totalPages = pages;
    if (_currentPage > pages) _currentPage = pages;
    notifyListeners();
  }

  // 독서 로그 저장(타이머 종료 시)
  Future<void> saveLog(
      Duration elapsed, {
        int? reachedPage,
        String? memo,
      }) async {
    // 페이지 갱신
    if (reachedPage != null) {
      final t = _totalPages ?? reachedPage;
      _currentPage = (t > 0 && reachedPage > t) ? t : reachedPage;
    }

    // DB 저장 (세션 생성 + 현재 페이지 동기화)
    final created = await _repo.addSession(
      isbn13,
      elapsed,
      _currentPage,
      memo: memo,
    );

    // 메모 포함하여 메모리 목록 갱신
    _logs.insert(
      0,
      ReadingLogVm(
        created.id,
        DateTime.now(),
        elapsed,
        _currentPage,
        memo: memo,
      ),
    );
    notifyListeners();
  }

  // 로그 삭제
  Future<void> deleteLog(String id) async {
    await _repo.deleteSession(id);
    _logs.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // == helpers ==
  Future<void> _refreshLogs() async {
    final list = await _repo.sessionsOf(isbn13);
    _logs
      ..clear()
      ..addAll(
        list.map(
              (s) => ReadingLogVm(
            s.id,
            s.createdAt,
            s.duration,
            s.reachedPage,
            memo: s.memo, // models.dart의 ReadingSession에 memo 필드가 있어야 함
          ),
        ),
      );
  }
}
