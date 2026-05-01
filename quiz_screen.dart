import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_session.dart';
import '../models/leaderboard_entry.dart';
import '../models/question.dart';
import '../services/leaderboard_service.dart';
import '../widgets/answer_option_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.session,
    required this.onLeaderboardChanged,
  });

  final GameSession session;
  final VoidCallback onLeaderboardChanged;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _secondsPerQuestion = 12;
  static const int _correctPoints = 10;
  static const int _wrongPenalty = 5;

  final LeaderboardService _leaderboardService = LeaderboardService();

  Timer? _timer;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _secondsLeft = _secondsPerQuestion;
  int? _selectedAnswerIndex;
  bool _isAnswerLocked = false;
  bool _didTimeOut = false;

  List<Question> get _questions => widget.session.questions;

  Question get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _secondsPerQuestion;
    });

    // Timer.periodic calls this function once every second until we cancel it.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 1) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _selectAnswer(int selectedIndex) async {
    if (_isAnswerLocked) return;

    final isCorrect = selectedIndex == _currentQuestion.correctAnswerIndex;
    final speedBonus = isCorrect ? _secondsLeft : 0;

    // Lock the question so the player cannot tap more than one answer.
    setState(() {
      _selectedAnswerIndex = selectedIndex;
      _isAnswerLocked = true;
      _didTimeOut = false;

      if (isCorrect) {
        _correctAnswers++;
        _score += _correctPoints + speedBonus;
      } else {
        _score -= _wrongPenalty;
      }
    });

    _timer?.cancel();

    // Built-in sound feedback keeps the app asset-free for beginners.
    await SystemSound.play(
      isCorrect ? SystemSoundType.click : SystemSoundType.alert,
    );

    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    _goToNextQuestion();
  }

  Future<void> _handleTimeout() async {
    if (_isAnswerLocked) return;

    setState(() {
      _isAnswerLocked = true;
      _didTimeOut = true;
      _score -= _wrongPenalty;
    });

    await SystemSound.play(SystemSoundType.alert);
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    _goToNextQuestion();
  }

  Future<void> _goToNextQuestion() async {
    _timer?.cancel();

    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    if (isLastQuestion) {
      await _finishQuiz();
      return;
    }

    // Reset selection state before showing the next question.
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _isAnswerLocked = false;
      _didTimeOut = false;
    });

    _startTimer();
  }

  Future<void> _finishQuiz() async {
    final categoryLabel = widget.session.category?.label ?? 'All Categories';

    await _leaderboardService.saveEntry(
      LeaderboardEntry(
        playerName: widget.session.playerName,
        score: _score,
        correctAnswers: _correctAnswers,
        totalQuestions: _questions.length,
        category: categoryLabel,
        difficulty: widget.session.difficulty.label,
        playedAt: DateTime.now(),
      ),
    );
    widget.onLeaderboardChanged();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: ResultScreen(
            playerName: widget.session.playerName,
            score: _score,
            correctAnswers: _correctAnswers,
            totalQuestions: _questions.length,
            category: categoryLabel,
            difficulty: widget.session.difficulty.label,
          ),
        ),
      ),
    );
  }

  AnswerState _answerState(int answerIndex) {
    final correctIndex = _currentQuestion.correctAnswerIndex;

    if (!_isAnswerLocked) {
      return AnswerState.idle;
    }

    if (answerIndex == correctIndex) {
      return AnswerState.correct;
    }

    if (!_didTimeOut && answerIndex == _selectedAnswerIndex) {
      return AnswerState.wrong;
    }

    return AnswerState.muted;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    final categoryLabel = widget.session.category?.label ?? 'All';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Costa Trivia Quiz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334E68),
                      ),
                    ),
                  ),
                  _TimerBadge(secondsLeft: _secondsLeft),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress,
                  backgroundColor: const Color(0xFFE1E8ED),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF0F8A5F)),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(text: categoryLabel, icon: Icons.category_rounded),
                  _InfoPill(
                    text: widget.session.difficulty.label,
                    icon: Icons.speed_rounded,
                  ),
                  _InfoPill(text: 'Score $_score', icon: Icons.bolt_rounded),
                ],
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Card(
                  key: ValueKey(_currentQuestion.text),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          _currentQuestion.text,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF102A43),
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _didTimeOut
                              ? 'Time up! Correct answer revealed.'
                              : 'Correct: +10 plus speed bonus. Wrong: -5.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF52616B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _currentQuestion.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return AnswerOptionCard(
                      label: String.fromCharCode(65 + index),
                      answer: _currentQuestion.options[index],
                      state: _answerState(index),
                      onTap: () => _selectAnswer(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final isLow = secondsLeft <= 4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFFE1E1) : const Color(0xFFE8F5EF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: 18,
            color: isLow ? const Color(0xFFE53935) : const Color(0xFF0F8A5F),
          ),
          const SizedBox(width: 6),
          Text(
            '${secondsLeft}s',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFE1E8ED)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F8A5F)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF243B53),
            ),
          ),
        ],
      ),
    );
  }
}
