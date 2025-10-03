import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/features/library/application/library_view_model.dart';
import 'package:bookmark/pages/widgets/capsule_header.dart';
import 'widgets/library_empty_view.dart';
import 'widgets/library_grid.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<LibraryViewModel>().load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();

    return SafeArea(
      top: true, bottom: false, left: false, right: false,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CapsuleHeader(title: '내 서재'),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: () {
              if (vm.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.error != null) {
                return Center(child: Text('오류: ${vm.error}'));
              }
              if (vm.items.isEmpty) {
                return const LibraryEmptyView();
              }
              return LibraryGrid(items: vm.items);
            }(),
          ),
        ],
      ),
    );
  }
}
