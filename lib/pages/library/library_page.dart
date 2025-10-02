import 'package:flutter/material.dart';
import 'package:bookmark/pages/widgets/capsule_header.dart';
import 'widgets/library_empty_view.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true, bottom: false, left: false, right: false,
      child: Column(
        children: const [
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CapsuleHeader(title: '내 서재'),
          ),
          SizedBox(height: 12),
          Expanded(child: LibraryEmptyView()),
        ],
      ),
    );
  }
}
