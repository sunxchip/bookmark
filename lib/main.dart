// lib/main.dart
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

import 'package:bookmark/data/repositories/sqlite_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로그인 없는 버전: 공용 아이디로 DB 먼저 오픈
  await SqliteRepository.I.openForUser('local');

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final ttbKey = const String.fromEnvironment('ALADIN_TTBKEY');
    final aladin = AladinApiService(ttbKey);

    final local = LibraryLocalDataSource();
    final LibraryRepository libRepo = LibraryRepositoryImpl(local);

    final resolver = PageCountResolver(aladin, libRepo);
    final searchRepo = SearchRepositoryImpl(aladin);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LibraryViewModel>(
          lazy: false,
          create: (_) => LibraryViewModel(libRepo),
        ),
        ChangeNotifierProvider<ReadingViewModel>(
          lazy: false,
          create: (_) => ReadingViewModel(libRepo, resolver),
        ),
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
