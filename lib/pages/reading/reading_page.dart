import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookmark/pages/widgets/capsule_header.dart';
import 'package:bookmark/features/reading/application/reading_view_model.dart';
import 'package:bookmark/pages/reading/widgets/reading_empty_view.dart';
import 'package:bookmark/pages/reading/widgets/reading_detail_view.dart';

class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true, bottom: false, left: false, right: false,
      child: Consumer<ReadingViewModel>(
        builder: (context, vm, _) {
          final session = vm.current;

          return Column(
              children: [
              const SizedBox(height: 12),
          const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CapsuleHeader(title: '이어읽기'),
          ),
          const SizedBox(height: 12),
          Expanded(
          child: session == null
          // 아무것도 없을 때: 기존 빈 화면 유지
              ? const ReadingEmptyView()
          // 세션이 생기면: 상세 스크롤 화면
              : ReadingDetailView(session: session),
          ),
          ],
          );
        },
      ),
    );
  }
}
