import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/search/application/search_view_model.dart';
import 'package:bookmark/features/search/data/aladin_api_service.dart';
import 'package:bookmark/features/search/data/search_repository_impl.dart';

import 'widgets/search_header.dart';
import 'widgets/search_results_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchViewModel _vm;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final key = const String.fromEnvironment('ALADIN_TTBKEY');
    final api = AladinApiService(key);
    final repo = SearchRepositoryImpl(api);
    _vm = SearchViewModel(repo);
  }

  @override
  void dispose() {
    _controller.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchViewModel>(
      create: (_) => _vm,
      child: Scaffold(
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchHeader(
                  controller: _controller,
                  readOnly: false,               // 실제 입력 가능
                  onChanged: _vm.onQueryChanged, // 실시간 검색
                  onSubmitted: _vm.onQueryChanged,
                ),
              ),
            ),
            const Expanded(child: SearchResultsList()),
          ],
        ),
      ),
    );
  }
}
