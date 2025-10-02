import 'package:flutter/material.dart';
import 'package:bookmark/nav/app_theme.dart';

class OrangeDivider extends StatelessWidget {
  const OrangeDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.orange,
      thickness: 1,
      height: 1,
    );
  }
}
