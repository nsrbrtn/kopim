import 'package:flutter/material.dart';

class HomeAccountIconBadge extends StatelessWidget {
  const HomeAccountIconBadge({
    super.key,
    required this.icon,
    required this.color,
  });

  static const double size = 28;

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
