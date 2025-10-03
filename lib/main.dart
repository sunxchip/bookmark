import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'nav/app_theme.dart';
import 'nav/home_shell.dart';


import 'package:bookmark/features/search/data/aladin_api_service.dart';
import 'package:bookmark/features/search/data/search_repository_impl.dart';
import 'package:bookmark/features/search/application/search_view_model.dart';


import 'package:bookmark/features/library/domain/library_repository.dart';
import 'package:bookmark/features/library/application/library_view_model.dart';
import 'package:bookmark/features/library/data/in_memory_library_repository.dart'; // ⬅️ 방금 만든 파일

void main() => runApp(const AppRoot());

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        Provider<LibraryRepository>(create: (_) => InMemoryLibraryRepository()),
        ChangeNotifierProvider<LibraryViewModel>(
          create: (ctx) => LibraryViewModel(ctx.read<LibraryRepository>()),
        ),

        // Search
        Provider<AladinApiService>(
          create: (_) => AladinApiService(
            const String.fromEnvironment('ALADIN_TTBKEY'),
          ),
        ),
        Provider<SearchRepositoryImpl>(
          create: (ctx) => SearchRepositoryImpl(ctx.read<AladinApiService>()),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (ctx) => SearchViewModel(ctx.read<SearchRepositoryImpl>()),
        ),
      ],
      child: MaterialApp(
        title: 'BottomNav Starter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeShell(),
      ),
    );
  }
}
