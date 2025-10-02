import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';
import 'package:bookmark/pages/widgets/capsule_header.dart';
import 'package:bookmark/features/reading/application/reading_view_model.dart';
import 'package:bookmark/pages/reading/widgets/reading_empty_view.dart';

class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  late final ReadingViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ReadingViewModel()..addListener(_onVmChanged)..load();
  }

  void _onVmChanged() => setState(() {});
  @override
  void dispose() { vm.removeListener(_onVmChanged); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final session = vm.current;

    return SafeArea(
      top: true, bottom: false, left: false, right: false,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CapsuleHeader(title: '이어읽기'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: session == null
                ? const ReadingEmptyView()
                : const Center(
              child: Text(
                '이어읽기 카드 UI (추후 구현)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
