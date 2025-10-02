import 'package:flutter/foundation.dart';
import '../domain/reading_session.dart';

class ReadingViewModel extends ChangeNotifier {
  ReadingSession? _current;
  ReadingSession? get current => _current;

  Future<void> load() async {
    // 초기엔 이어읽기 없음 → 빈 화면 노출
    _current = null;
    notifyListeners();
  }

  Future<void> setCurrent(ReadingSession session) async {
    _current = session;
    notifyListeners();
  }

  Future<void> clear() async {
    _current = null;
    notifyListeners();
  }
}
