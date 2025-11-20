import 'package:flutter/material.dart';

class ProgressHeader extends StatelessWidget {
  final double progress; // 0~1
  const ProgressHeader({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final p = (progress * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(value: progress, minHeight: 10),
        ),
        const SizedBox(height: 8),
        Text('읽기 중 $p %', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
