import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'pages/game/game_page.dart';

class StellaBusJamApp extends StatelessWidget {
  const StellaBusJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stella Bus Jam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GamePage(),
    );
  }
}