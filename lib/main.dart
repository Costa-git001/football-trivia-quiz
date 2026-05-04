import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // The app can still run with local fallback questions before Firebase setup.
  }

  runApp(const CostaTriviaQuizApp());
}

class CostaTriviaQuizApp extends StatelessWidget {
  const CostaTriviaQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Costa Trivia Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F8A5F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          foregroundColor: Color(0xFF102A43),
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F8A5F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
