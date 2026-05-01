class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
    required this.playedAt,
  });

  final String playerName;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String category;
  final String difficulty;
  final DateTime playedAt;

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'category': category,
      'difficulty': difficulty,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String? ?? 'Player',
      score: json['score'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      category: json['category'] as String? ?? 'Mixed',
      difficulty: json['difficulty'] as String? ?? 'Easy',
      playedAt: DateTime.tryParse(json['playedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
