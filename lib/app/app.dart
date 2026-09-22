import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import 'theme.dart';

/// Root widget of the application.
class CredApp extends StatelessWidget {
  const CredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cred',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Keeps the tight card layout intact when the system font size is
      // increased.
      builder: (BuildContext context, Widget? child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
      home: const HomeScreen(),
    );
  }
}
