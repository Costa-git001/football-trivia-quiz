import 'package:flutter/material.dart';

class SelectionChip extends StatelessWidget {
  const SelectionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF243B53),
        fontWeight: FontWeight.w700,
      ),
      selectedColor: const Color(0xFF0F8A5F),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF0F8A5F) : const Color(0xFFE1E8ED),
      ),
    );
  }
}
