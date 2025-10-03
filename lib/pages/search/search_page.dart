import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/search_results_list.dart';
import 'package:bookmark/features/search/application/search_view_model.dart';
import 'package:bookmark/features/search/data/aladin_api_service.dart';
import 'package:bookmark/features/search/data/search_repository_impl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _lastInput;
  final Duration _debounce = const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchViewModel>(
      create: (_) {
        const key = String.fromEnvironment('ALADIN_TTBKEY');
        final api = AladinApiService(key);
        final repo = SearchRepositoryImpl(api);
        return SearchViewModel(repo);
      },
      builder: (context, _) {
        return SafeArea(
          top: true, bottom: false, left: false, right: false,
          child: Column(
            children: [
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: '책 제목, 저자, 키워드…',
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => context.read<SearchViewModel>().search(_controller.text),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (_) {
                    _lastInput = DateTime.now();
                    Future.delayed(_debounce, () {
                      final now = DateTime.now();
                      if (_lastInput != null && now.difference(_lastInput!) >= _debounce) {
                        if (mounted) context.read<SearchViewModel>().search(_controller.text);
                      }
                    });
                  },
                  onSubmitted: (v) => context.read<SearchViewModel>().search(v),
                ),
              ),

              const SizedBox(height: 8),

              // 상태별: 스켈레톤/결과 리스트는 SearchResultsList 내부에서 처리
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SearchResultsList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
