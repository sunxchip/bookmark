import 'dart:async';
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

/// 이어읽기 화면용 컨트롤러 (MVVM: ViewModel 역할)
class ReadingDetailController extends ChangeNotifier {
  final _repo = SqliteRepository.I;

  late ReadingSession _base; // 진입 시 스냅샷
  bool _initialized = false;

  int? _totalPages;          // 총 페이지 (shelf_items.totalPages)
  int _currentPage = 0;      // 현재 페이지 (shelf_items.currentPage)
  final List<ReadingLogVm> _logs = [];

  StreamSubscription<void>? _subChanges; // repo 변화 구독

  // ===== lifecycle =====
  Future<void> init(ReadingSession session) async {
    _base = session;

    // 진입 직후: 스냅샷으로 초기값 채움
    _currentPage = session.lastPage ?? 0;
    _totalPages   = session.totalPages ?? session.book.pageCount;

    // DB에서 실제값 동기
    await _refreshShelf();
    await _refreshLogs();

    // repo 변경 스트림 구독 → 내서재/다른 화면에서 변경돼도 즉시 반영
    _subChanges?.cancel();
    _subChanges = _repo.changes.listen((_) async {
      await _refreshShelf();
      await _refreshLogs();
      notifyListeners();
    });

    _initialized = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subChanges?.cancel();
    super.dispose();
  }

  // ===== getters =====
  bool get initialized => _initialized;

  String get isbn13 => _base.book.isbn13;
  String get title   => _base.book.title;
  String get author  => _base.book.author;
  String get cover   => _base.book.coverUrl;

  int?  get totalPages  => _totalPages;
  int   get currentPage => _currentPage;

  List<ReadingLogVm> get logs => List.unmodifiable(_logs);

  double get progress {
    final t = _totalPages ?? 0;
    if (t <= 0) return 0;
    return (_currentPage / t).clamp(0, 1).toDouble();
  }

  // ===== commands =====

  /// 총 페이지 설정 (다이얼로그/파싱 결과)
  Future<void> setTotalPages(int pages) async {
    if (pages <= 0) return;
    await _repo.setTotalPages(isbn13, pages); // 반드시 await
    await _refreshShelf();                    // DB에서 다시 읽어 일관성 보장
    notifyListeners();
  }

  /// 독서 로그 저장 (타이머 정지 후)
  Future<void> saveLog(
      Duration elapsed, {
        int? reachedPage,
        String? memo,
      }) async {
    // 페이지 갱신(상한은 총 페이지)
    if (reachedPage != null) {
      final t = _totalPages ?? reachedPage;
      _currentPage = (t > 0 && reachedPage > t) ? t : reachedPage;
    }

    // 세션 추가 + 현재페이지 동기화
    await _repo.addSession(
      isbn13,
      elapsed,
      _currentPage,
      memo: memo,
    );

    // DB 상태 재동기
    await _refreshShelf();
    await _refreshLogs();
    notifyListeners();
  }

  /// 로그 삭제
  Future<void> deleteLog(String id) async {
    await _repo.deleteSession(id);
    await _refreshLogs();
    // 삭제가 현재페이지에 영향은 없지만, 외부에서 수정됐을 수 있으니 한번 동기화
    await _refreshShelf();
    notifyListeners();
  }

  // ===== helpers =====

  /// shelf_items/ books로부터 현재 페이지/총 페이지 최신화
  Future<void> _refreshShelf() async {
    final shelf = await _repo.getShelf(isbn13);
    if (shelf != null) {
      _currentPage = shelf.currentPage;
      _totalPages  = shelf.totalPages ?? _totalPages;
    }
  }

  /// reading_sessions → 화면용 로그 목록 변환
  Future<void> _refreshLogs() async {
    final list = await _repo.sessionsOf(isbn13);
    _logs
      ..clear()
      ..addAll(list.map((s) => ReadingLogVm(
        s.id,
        s.createdAt,
        s.duration,
        s.reachedPage,
        memo: s.memo,
      )));
  }
}
