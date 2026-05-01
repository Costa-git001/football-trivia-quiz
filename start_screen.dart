import 'dart:math';

import 'package:flutter/material.dart';

import '../data/questions.dart';
import '../models/game_session.dart';
import '../models/leaderboard_entry.dart';
import '../models/question.dart';
import '../services/leaderboard_service.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/selection_chip.dart';
import 'quiz_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  static const int _maxQuestionsPerGame = 10;

  final LeaderboardService _leaderboardService = LeaderboardService();
  final TextEditingController _playerNameController = TextEditingController();

  QuestionCategory? _selectedCategory;
  QuestionDifficulty _selectedDifficulty = QuestionDifficulty.medium;
  List<LeaderboardEntry> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    final entries = await _leaderboardService.loadLeaderboard();

    if (!mounted) return;
    setState(() {
      _leaderboard = entries;
    });
  }

  bool _isAllowedDifficulty(Question question) {
    return question.difficulty.index <= _selectedDifficulty.index;
  }

  List<Question> _buildRandomSessionQuestions() {
    final matchingQuestions = footballQuestions.where((question) {
      final matchesCategory =
          _selectedCategory == null || question.category == _selectedCategory;
      return matchesCategory && _isAllowedDifficulty(question);
    }).toList();

    matchingQuestions.shuffle(Random());
    return matchingQuestions.take(_maxQuestionsPerGame).toList();
  }

  void _startGame() {
    final questions = _buildRandomSessionQuestions();
    final typedName = _playerNameController.text.trim();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: QuizScreen(
            session: GameSession(
              playerName: typedName.isEmpty ? 'Player' : typedName,
              category: _selectedCategory,
              difficulty: _selectedDifficulty,
              questions: questions,
            ),
            onLeaderboardChanged: _loadLeaderboard,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final highScore = _leaderboard.isEmpty ? 0 : _leaderboard.first.score;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            const Icon(
              Icons.sports_soccer,
              size: 78,
              color: Color(0xFF0F8A5F),
            ),
            const SizedBox(height: 18),
            Text(
              'Costa Trivia Quiz',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF102A43),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fast football questions. Bigger points for faster answers.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF52616B),
                  ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _playerNameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Player name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.person_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE1E8ED)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle(
              icon: Icons.category_rounded,
              title: 'Category',
              subtitle: 'Choose a topic or play everything.',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SelectionChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...QuestionCategory.values.map(
                  (category) => SelectionChip(
                    label: category.label,
                    isSelected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _SectionTitle(
              icon: Icons.speed_rounded,
              title: 'Difficulty',
              subtitle: 'Higher levels include easier warm-up questions too.',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: QuestionDifficulty.values.map((difficulty) {
                return SelectionChip(
                  label: difficulty.label,
                  isSelected: _selectedDifficulty == difficulty,
                  onTap: () => setState(() => _selectedDifficulty = difficulty),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F8A5F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Best score: $highScore pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            LeaderboardCard(entries: _leaderboard),
            const SizedBox(height: 26),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _startGame,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start Game',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F8A5F)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF102A43),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF52616B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
