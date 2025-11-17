import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';

class BottomNavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  const BottomNavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: isSelected ? 28 : 24,
      color: isSelected ? AppTheme.lightModeBlack : AppTheme.lightModeLightGrey,
    );
  }
}
