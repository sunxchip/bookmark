import 'dart:async';
import 'package:flutter/foundation.dart';

class ReadingTimerViewModel extends ChangeNotifier {
  Timer? _ticker;
  DateTime? _startedAt;
  Duration _accum = Duration.zero;
  bool _running = false;

  bool get isRunning => _running;

  Duration get elapsed {
    final live = (_running && _startedAt != null)
        ? DateTime.now().difference(_startedAt!)
        : Duration.zero;
    return _accum + live;
  }

  void start() {
    if (_running) return;
    _running = true;
    _startedAt = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    notifyListeners();
  }

  void pause() {
    if (!_running || _startedAt == null) return;
    _accum += DateTime.now().difference(_startedAt!);
    _startedAt = null;
    _running = false;
    _ticker?.cancel();
    notifyListeners();
  }

  void reset() {
    // 실행 중이면 누락분을 먼저 반영한 뒤 끔
    if (_running && _startedAt != null) {
      _accum += DateTime.now().difference(_startedAt!);
    }
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
    _accum = Duration.zero;
    _running = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}