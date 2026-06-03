import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/badge_info.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.fromBadgeInfo(BadgeInfo info) =>
      StatusBadge(label: info.label, color: info.color);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.fromLabel(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
