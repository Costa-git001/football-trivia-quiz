enum QuestionCategory {
  premierLeague,
  championsLeague,
  worldCup,
  players,
  rules,
  international,
  clubs,
  managers,
}

enum QuestionDifficulty {
  easy,
  medium,
  hard,
}

extension QuestionCategoryLabel on QuestionCategory {
  String get label {
    switch (this) {
      case QuestionCategory.premierLeague:
        return 'Premier League';
      case QuestionCategory.championsLeague:
        return 'Champions League';
      case QuestionCategory.worldCup:
        return 'World Cup';
      case QuestionCategory.players:
        return 'Players';
      case QuestionCategory.rules:
        return 'Rules';
      case QuestionCategory.international:
        return 'International';
      case QuestionCategory.clubs:
        return 'Clubs';
      case QuestionCategory.managers:
        return 'Managers';
    }
  }

  static QuestionCategory fromLabel(String value) {
    final normalized = value.trim().toLowerCase();

    for (final category in QuestionCategory.values) {
      if (category.label.toLowerCase() == normalized) {
        return category;
      }
    }

    return QuestionCategory.worldCup;
  }
}

extension QuestionDifficultyLabel on QuestionDifficulty {
  String get label {
    switch (this) {
      case QuestionDifficulty.easy:
        return 'Easy';
      case QuestionDifficulty.medium:
        return 'Medium';
      case QuestionDifficulty.hard:
        return 'Hard';
    }
  }

  static QuestionDifficulty fromLabel(String value) {
    final normalized = value.trim().toLowerCase();

    for (final difficulty in QuestionDifficulty.values) {
      if (difficulty.label.toLowerCase() == normalized) {
        return difficulty;
      }
    }

    return QuestionDifficulty.easy;
  }
}

class Question {
  const Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
  });

  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;

  factory Question.fromFirestore(Map<String, dynamic> data) {
    final options = (data['options'] as List<dynamic>? ?? [])
        .map((option) => option.toString())
        .toList();

    return Question(
      text: data['question'] as String? ?? '',
      options: options,
      correctAnswerIndex: data['answerIndex'] as int? ?? 0,
      category: QuestionCategoryLabel.fromLabel(
        data['category'] as String? ?? 'World Cup',
      ),
      difficulty: QuestionDifficultyLabel.fromLabel(
        data['difficulty'] as String? ?? 'easy',
      ),
    );
  }
}
