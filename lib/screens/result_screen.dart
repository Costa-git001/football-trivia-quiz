import 'package:flutter/material.dart';

import '../data/questions.dart';
import '../services/high_score_service.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  final int score;
  final int totalQuestions;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final HighScoreService _highScoreService = HighScoreService();
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final savedScore = await _highScoreService.loadHighScore();

    if (!mounted) return;
    setState(() {
      _highScore = savedScore;
    });
  }

  void _playAgain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          questions: footballQuestions,
          onHighScoreChanged: _loadHighScore,
        ),
      ),
    );
  }

  String get _message {
    final percent = widget.score / widget.totalQuestions;

    if (percent == 1) return 'Perfect score!';
    if (percent >= 0.7) return 'Great football knowledge!';
    if (percent >= 0.4) return 'Nice effort. Keep training!';
    return 'Warm up and try again!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 88,
                  color: Color(0xFFFFB703),
                ),
                const SizedBox(height: 24),
                Text(
                  'Final Score',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF102A43),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.score}/${widget.totalQuestions}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F8A5F),
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF52616B),
                      ),
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'High Score: $_highScore/${widget.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F8A5F),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _playAgain,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
