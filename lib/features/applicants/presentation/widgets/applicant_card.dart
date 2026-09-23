import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../utils/relative_time.dart';
import 'applicant_avatar.dart';
import 'applicant_status_badge.dart';

class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    required this.applicant,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final Applicant applicant;
  final VoidCallback onTap;
  /// Null deshabilita el botón (guardando o sin cupos).
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  bool get _isPending => applicant.status == ApplicantStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ApplicantAvatar(name: applicant.name, avatarUrl: applicant.avatarUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: const TextStyle(
                        color: NodoColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatRelativeSubmittedAt(applicant.submittedAt),
                      style: const TextStyle(
                        color: NodoColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ApplicantStatusBadge(status: applicant.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            applicant.motivation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: NodoColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isPending ? 'Ver más detalle' : 'Ver perfil completo',
                  style: const TextStyle(
                    color: Color(0xFF5B3FA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Color(0xFF5B3FA8),
                ),
              ],
            ),
          ),
          if (_isPending) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    label: 'Rechazar',
                    backgroundColor: const Color(0xFFFFEBEC),
                    textColor: const Color(0xFFBF3845),
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    label: 'Aceptar',
                    backgroundColor: NodoColors.primary,
                    textColor: Colors.white,
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? backgroundColor.withValues(alpha: 0.45)
          : backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
