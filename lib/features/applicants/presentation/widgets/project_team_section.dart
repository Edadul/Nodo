import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../domain/entities/team_member.dart';

class ProjectTeamSection extends StatelessWidget {
  const ProjectTeamSection({
    super.key,
    required this.members,
    this.spotsLabel,
    this.compact = false,
  });

  final List<TeamMember> members;
  final String? spotsLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Equipo',
                style: TextStyle(
                  color: NodoColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (spotsLabel != null)
              Text(
                spotsLabel!,
                style: const TextStyle(
                  color: NodoColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (members.isEmpty)
          const Text(
            'Aún no hay integrantes aceptados.',
            style: TextStyle(
              color: NodoColors.textSecondary,
              fontSize: 13.5,
            ),
          )
        else
          ...members.map(
            (member) => Padding(
              padding: EdgeInsets.only(bottom: compact ? 8 : 10),
              child: _TeamMemberTile(member: member, compact: compact),
            ),
          ),
      ],
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({required this.member, required this.compact});

  final TeamMember member;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final avatarSize = compact ? 36.0 : 40.0;
    return Row(
      children: [
        CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: NodoColors.primaryMuted,
          backgroundImage: member.avatarUrl != null &&
                  member.avatarUrl!.trim().isNotEmpty
              ? NetworkImage(member.avatarUrl!)
              : null,
          child: member.avatarUrl == null || member.avatarUrl!.trim().isEmpty
              ? Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: NodoColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 14 : 15,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: NodoColors.textPrimary,
                ),
              ),
              if (!compact && member.program.trim().isNotEmpty)
                Text(
                  member.program,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NodoColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: member.isCreator
                ? NodoColors.primaryMuted
                : NodoColors.chipInactive,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            member.roleLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: member.isCreator
                  ? NodoColors.primaryDark
                  : NodoColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
