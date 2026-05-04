import 'package:flutter/material.dart';

import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import '../widgets/leaderboard_card.dart';
import 'start_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.playerName,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
  });

  final String playerName;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String category;
  final String difficulty;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  List<LeaderboardEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final entries = await _leaderboardService.loadLeaderboard();

    if (!mounted) return;
    setState(() {
      _leaderboard = entries;
    });
  }

  void _playAgain() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const StartScreen(),
        ),
      ),
      (_) => false,
    );
  }

  String get _message {
    final percent = widget.correctAnswers / widget.totalQuestions;

    if (percent == 1) return 'Football Genius!';
    if (percent >= 0.7) return 'Great job!';
    if (percent >= 0.4) return 'Good effort!';
    return 'Keep practicing!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.emoji_events_rounded,
              size: 88,
              color: Color(0xFFFFB703),
            ),
            const SizedBox(height: 22),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF102A43),
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.playerName}, you scored',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF52616B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.score} pts',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F8A5F),
                  ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _ResultStat(
                    label: 'Correct',
                    value: '${widget.correctAnswers}/${widget.totalQuestions}',
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultStat(
                    label: 'Mode',
                    value: widget.difficulty,
                    icon: Icons.speed_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ResultStat(
              label: 'Category',
              value: widget.category,
              icon: Icons.category_rounded,
            ),
            const SizedBox(height: 22),
            LeaderboardCard(entries: _leaderboard),
            const SizedBox(height: 30),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _playAgain,
                icon: const Icon(Icons.replay_rounded),
                label: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8ED)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0F8A5F)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF52616B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF102A43),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
