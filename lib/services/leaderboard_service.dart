import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static const String _leaderboardKey = 'leaderboard_entries';
  static const int _maxEntries = 5;

  Future<List<LeaderboardEntry>> loadLeaderboard() async {
    final preferences = await SharedPreferences.getInstance();
    final savedEntries = preferences.getStringList(_leaderboardKey) ?? [];

    final entries = savedEntries.map((entry) {
      final json = jsonDecode(entry) as Map<String, dynamic>;
      return LeaderboardEntry.fromJson(json);
    }).toList();

    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries.take(_maxEntries).toList();
  }

  Future<void> saveEntry(LeaderboardEntry entry) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = await loadLeaderboard();

    entries.add(entry);
    entries.sort((a, b) => b.score.compareTo(a.score));

    final encodedEntries = entries
        .take(_maxEntries)
        .map((leaderboardEntry) => jsonEncode(leaderboardEntry.toJson()))
        .toList();

    await preferences.setStringList(_leaderboardKey, encodedEntries);
  }

  Future<int> loadHighScore() async {
    final leaderboard = await loadLeaderboard();
    return leaderboard.isEmpty ? 0 : leaderboard.first.score;
  }
}
