import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'theme.dart';

void main() {
  runApp(const MetalProApp());
}

class MetalProApp extends StatelessWidget {
  const MetalProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'MetalPro — Ağırlık Hesaplayıcı',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
