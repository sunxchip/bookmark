import 'package:flutter/material.dart';
import 'package:bookmark/features/reading/application/reading_detail_controller.dart';
import 'package:bookmark/pages/reading/widgets/parts/reading_log_sheet.dart';

class ReadingLogGrid extends StatelessWidget {
  const ReadingLogGrid({
    super.key,
    required this.logs,
    required this.bookTitle,
    required this.coverUrl,
    required this.onDelete,
  });

  final List<ReadingLogVm> logs;
  final String bookTitle;
  final String coverUrl;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('아직 기록이 없습니다.'),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, i) {
          final e = logs[i];
          final d = '${e.createdAt.month}월 ${e.createdAt.day}일';
          final mins = e.duration.inMinutes;

          return _LogTile(
            date: d,
            minutes: mins,
            page: e.reachedPage,
            onTap: () async {
              await ReadingLogActionSheet.show(
                context,
                bookTitle: bookTitle,
                coverUrl: coverUrl,
                log: e,
                onDelete: () => onDelete(e.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.date,
    required this.minutes,
    required this.page,
    required this.onTap,
  });

  final String date;
  final int minutes;
  final int page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(date, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 6),
                Text(
                  '${minutes}분',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text('P.$page', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
