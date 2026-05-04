import 'package:flutter/material.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({
    super.key,
    required this.entries,
  });

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: Color(0xFF0F8A5F)),
              SizedBox(width: 8),
              Text(
                'Local Leaderboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF102A43),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text(
              'No scores yet. Be the first on the board.',
              style: TextStyle(color: Color(0xFF52616B)),
            )
          else
            ...entries.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final score = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text(
                        '#$rank',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        score.playerName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${score.score} pts',
                      style: const TextStyle(
                        color: Color(0xFF0F8A5F),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
