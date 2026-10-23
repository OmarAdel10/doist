import 'package:flutter/material.dart';

/// An action chip for the AI quick actions row ("Break down task",
/// "Prioritize my day"). Pass a null [onTap] to disable the chip.
class AiActionChip extends StatelessWidget {
  const AiActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
