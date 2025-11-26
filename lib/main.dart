import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nav/home_shell.dart';
import 'nav/app_theme.dart';

// 검색
import 'package:bookmark/features/search/data/aladin_api_service.dart';
import 'package:bookmark/features/search/data/search_repository_impl.dart';

// 서재
import 'package:bookmark/features/library/data/library_local.dart';
import 'package:bookmark/features/library/data/library_repository_impl.dart';
import 'package:bookmark/features/library/application/library_view_model.dart';
import 'package:bookmark/features/library/domain/library_repository.dart';

// 페이지 LookUp + 이어읽기
import 'package:bookmark/features/library/application/page_count_resolver.dart';
import 'package:bookmark/features/reading/application/reading_view_model.dart';

void main() => runApp(const AppRoot());

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // 의존성
    final ttbKey = const String.fromEnvironment('ALADIN_TTBKEY');
    final aladin = AladinApiService(ttbKey);

    final local = LibraryLocalDataSource();
    final LibraryRepository libRepo = LibraryRepositoryImpl(local);

    final resolver = PageCountResolver(aladin, libRepo);
    final searchRepo = SearchRepositoryImpl(aladin);

    return MultiProvider(
      providers: [
        // 내 서재 VM도 탭 이동 시 dispose 되지 않도록 lazy: false
        ChangeNotifierProvider<LibraryViewModel>(
          lazy: false,
          create: (_) => LibraryViewModel(libRepo),
        ),
        // 이어읽기 VM: 반드시 앱 최상단에서 '하나만' 생성
        ChangeNotifierProvider<ReadingViewModel>(
          lazy: false,
          create: (_) => ReadingViewModel(libRepo, resolver),
        ),
        // 검색 레포 (필요시 read< SearchRepositoryImpl >로 사용)
        Provider<SearchRepositoryImpl>.value(value: searchRepo),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const HomeShell(),
      ),
    );
  }
}
