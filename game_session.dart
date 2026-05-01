import 'question.dart';

class GameSession {
  const GameSession({
    required this.playerName,
    required this.category,
    required this.difficulty,
    required this.questions,
  });

  final String playerName;
  final QuestionCategory? category;
  final QuestionDifficulty difficulty;
  final List<Question> questions;
}
