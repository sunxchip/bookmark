import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookmark/pages/widgets/capsule_header.dart';
import 'package:bookmark/features/reading/application/reading_view_model.dart';
import 'package:bookmark/features/reading/application/reading_timer_view_model.dart';
import 'package:bookmark/pages/reading/widgets/reading_empty_view.dart';
import 'package:bookmark/pages/reading/widgets/reading_detail_view.dart';

class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReadingTimerViewModel(),
      child: SafeArea(
        top: true, bottom: false, left: false, right: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CapsuleHeader(title: '이어읽기'),
            ),
            const SizedBox(height: 12),

            //VM의 current만 추적하고, 세션이 바뀌면 isbn13 Key로 강제 교체
            Expanded(
              child: Selector<ReadingViewModel, ReadingSessionKey?>(
                selector: (_, vm) {
                  final s = vm.current;
                  if (s == null) return null;
                  return ReadingSessionKey(isbn13: s.book.isbn13, session: s);
                },
                builder: (context, k, _) {
                  if (k == null) return const ReadingEmptyView();
                  return ReadingDetailView(
                    key: ValueKey(k.isbn13),   // ← 다른 책이 되면 위젯 교체
                    session: k.session,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ReadingSessionKey {
  final String isbn13;
  final dynamic session;
  ReadingSessionKey({required this.isbn13, required this.session});
}
