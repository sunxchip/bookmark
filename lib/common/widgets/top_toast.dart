import 'dart:async';
import 'package:flutter/material.dart';

Future<void> showTopToast(
    BuildContext context, {
      required String message,
      Duration duration = const Duration(seconds: 2),
      double backdropOpacity = 0.4,
      bool dismissible = false,
    }) async {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final theme = Theme.of(context);
  late OverlayEntry entry;

  void remove() {
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) {
      return Stack(
        children: [

          Positioned.fill(
            child: GestureDetector(
              onTap: dismissible ? remove : null,
              child: Container(
                color: Colors.black.withOpacity(backdropOpacity),
              ),
            ),
          ),


          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(entry);

  await Future<void>.delayed(duration);
  remove();
}
