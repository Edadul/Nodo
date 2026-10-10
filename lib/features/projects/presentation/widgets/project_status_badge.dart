import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../domain/entities/project_status.dart';

class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({super.key, required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      ProjectStatus.idea => (
          bg: NodoColors.primaryMuted,
          fg: NodoColors.primaryDark,
        ),
      ProjectStatus.inProgress => (
          bg: const Color(0xFFE3F6ED),
          fg: const Color(0xFF1B7A4E),
        ),
      ProjectStatus.closed => (
          bg: NodoColors.chipInactive,
          fg: NodoColors.textSecondary,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.fg,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
