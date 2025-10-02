import 'package:flutter/material.dart';
import 'nav/app_theme.dart';
import 'nav/home_shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BottomNav Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // 보여주신 톤에 맞춘 다크 테마
      home: const HomeShell(),
    );
  }
}
