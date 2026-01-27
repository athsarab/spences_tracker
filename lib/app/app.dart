import 'package:flutter/material.dart';

import '../features/expenses/presentation/screens/home_screen.dart';
import 'theme/app_theme.dart';

class SpencesApp extends StatelessWidget {
  const SpencesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spences',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
