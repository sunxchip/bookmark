import 'package:flutter/foundation.dart';

class TabNav {
  TabNav._();
  static final TabNav I = TabNav._();

  /// 0: 이어읽기, 1: 검색, 2: 서재
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  void go(int index) => selectedIndex.value = index;
}
