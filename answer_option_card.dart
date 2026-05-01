import 'package:flutter/material.dart';

enum AnswerState {
  idle,
  correct,
  wrong,
  muted,
}

class AnswerOptionCard extends StatelessWidget {
  const AnswerOptionCard({
    super.key,
    required this.label,
    required this.answer,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String answer;
  final AnswerState state;
  final VoidCallback onTap;

  Color get _backgroundColor {
    switch (state) {
      case AnswerState.correct:
        return const Color(0xFFDFF7E8);
      case AnswerState.wrong:
        return const Color(0xFFFFE1E1);
      case AnswerState.muted:
        return Colors.white;
      case AnswerState.idle:
        return Colors.white;
    }
  }

  Color get _borderColor {
    switch (state) {
      case AnswerState.correct:
        return const Color(0xFF21A366);
      case AnswerState.wrong:
        return const Color(0xFFE53935);
      case AnswerState.muted:
        return const Color(0xFFE1E8ED);
      case AnswerState.idle:
        return const Color(0xFFE1E8ED);
    }
  }

  IconData? get _icon {
    switch (state) {
      case AnswerState.correct:
        return Icons.check_circle_rounded;
      case AnswerState.wrong:
        return Icons.cancel_rounded;
      case AnswerState.muted:
      case AnswerState.idle:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: state == AnswerState.idle ? 1 : 0.98,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF0F8A5F),
                  foregroundColor: Colors.white,
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF243B53),
                    ),
                  ),
                ),
                if (_icon != null) ...[
                  const SizedBox(width: 10),
                  Icon(
                    _icon,
                    color: state == AnswerState.correct
                        ? const Color(0xFF21A366)
                        : const Color(0xFFE53935),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
