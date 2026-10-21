import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../domain/entities/project_update.dart';
import 'project_status_badge.dart';

class ProjectUpdatesTimeline extends StatelessWidget {
  const ProjectUpdatesTimeline({
    super.key,
    required this.updates,
    this.emptyMessage =
        'Aún no hay actualizaciones. El equipo puede publicar el avance del proyecto.',
  });

  final List<ProjectUpdate> updates;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NodoColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NodoColors.chipBorder),
        ),
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: NodoColors.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < updates.length; i++)
          _TimelineEntry(
            key: ValueKey('timeline-entry-${updates[i].id}'),
            update: updates[i],
            isFirst: i == 0,
            isLast: i == updates.length - 1,
          ),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    super.key,
    required this.update,
    required this.isFirst,
    required this.isLast,
  });

  final ProjectUpdate update;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final date = _formatTimelineDate(update.createdAt.toLocal());

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst ? NodoColors.primary : NodoColors.surface,
                    border: Border.all(
                      color: NodoColors.primary,
                      width: 2.5,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: NodoColors.chipBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NodoColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: NodoColors.chipBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            date,
                            style: const TextStyle(
                              color: NodoColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (update.status != null)
                          ProjectStatusBadge(status: update.status!),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      update.title,
                      style: const TextStyle(
                        color: NodoColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      update.body,
                      style: const TextStyle(
                        color: NodoColors.textSecondary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      update.authorName,
                      style: const TextStyle(
                        color: NodoColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formato corto en español sin `initializeDateFormatting` (falla en web).
String _formatTimelineDate(DateTime date) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final day = date.day;
  final month = months[date.month - 1];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day $month · $hour:$minute';
}
