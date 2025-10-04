import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:bookmark/pages/reading/reading_page.dart';
import 'package:bookmark/pages/search/search_page.dart';
import 'package:bookmark/pages/library/library_page.dart';
import 'package:bookmark/nav/tab_nav.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _pages = <Widget>[
    ReadingPage(),
    SearchPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: TabNav.I.selectedIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.orange, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => TabNav.I.go(i),
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
      },
    );
  }
}
