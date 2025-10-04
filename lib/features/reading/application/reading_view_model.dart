import 'package:flutter/foundation.dart';
import 'package:bookmark/features/reading/domain/reading_session.dart';

class ReadingViewModel extends ChangeNotifier {
  ReadingSession? _current;
  ReadingSession? get current => _current;

  /// 이어읽기 세션이 없는 상태(빈 화면 노출 여부)
  bool get isEmpty => _current == null;

  /// 초기 로드: 기본은 비어 있는 상태로 시작
  Future<void> load() async {
    _current = null;
    notifyListeners();
  }

  /// 외부에서 선택된 세션을 열 때 사용 (서재 카드 탭)
  void open(ReadingSession session) {
    _current = session;
    notifyListeners();
  }

  /// 기존 메서드와의 호환을 위해 유지
  Future<void> setCurrent(ReadingSession session) async {
    open(session);
  }

  /// 이어읽기 상태 비우기 (빈 화면으로 전환)
  Future<void> clear() async {
    _current = null;
    notifyListeners();
  }
}
