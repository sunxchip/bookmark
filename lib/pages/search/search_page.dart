import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';
import 'package:bookmark/pages/widgets/orange_divider.dart';
import 'widgets/search_header.dart';
import 'widgets/search_skeleton_list.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      top: true,
      bottom: false,
      left: false,
      right: false,
      child: Column(
        children: const [
          SizedBox(height: 12),


          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SearchHeader(),
          ),


          SizedBox(height: 8),

          Expanded(child: SearchSkeletonList()),
        ],
      ),
    );
  }
}
