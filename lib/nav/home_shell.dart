import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:bookmark/pages/reading/reading_page.dart';
import 'package:bookmark/pages/search/search_page.dart';
import 'package:bookmark/pages/library/library_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    ReadingPage(),
    SearchPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면 유지 (탭 전환 시 상태 보존)
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          // 스크린샷처럼 상단 오렌지 라인
          border: Border(
            top: BorderSide(color: AppColors.orange, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: '이어읽기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              label: '서재',
            ),
          ],
        ),
      ),
    );
  }
}
