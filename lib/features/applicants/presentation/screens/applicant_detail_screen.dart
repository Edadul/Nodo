import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../viewmodels/applicants_view_model.dart';
import '../widgets/applicant_avatar.dart';
import '../widgets/applicants_screen_header.dart';

class ApplicantDetailScreen extends StatefulWidget {
  const ApplicantDetailScreen({
    super.key,
    required this.applicantId,
    required this.viewModel,
  });

  final int applicantId;
  final ApplicantsViewModel viewModel;

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  bool _isUpdating = false;

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  Future<void> _decide(Applicant applicant, ApplicantStatus status) async {
    setState(() => _isUpdating = true);
    final updated = await widget.viewModel.updateStatus(applicant.id, status);
    if (!mounted) return;
    setState(() => _isUpdating = false);

    if (updated != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == ApplicantStatus.accepted
                ? '${applicant.name} fue aceptado/a'
                : '${applicant.name} fue rechazado/a',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: NodoColors.primaryDark,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage ?? 'No se pudo actualizar'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: NodoColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicant = widget.viewModel.findById(widget.applicantId);

    return Scaffold(
      backgroundColor: NodoColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ApplicantsScreenHeader(title: 'Perfil del postulante'),
            Expanded(
              child: applicant == null
                  ? const Center(
                      child: Text(
                        'Postulante no encontrado',
                        style: TextStyle(color: NodoColors.textSecondary),
                      ),
                    )
                  : _buildBody(applicant),
            ),
          ],
        ),
      ),
      bottomNavigationBar: applicant == null
          ? null
          : _buildFooter(applicant),
    );
  }

  Widget _buildBody(Applicant applicant) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ProfileHeaderCard(applicant: applicant),
        const SizedBox(height: 16),
        _MotivationCard(motivation: applicant.motivation),
        if (applicant.hasAttachment) ...[
          const SizedBox(height: 16),
          _AttachmentCard(applicant: applicant),
        ],
        const SizedBox(height: 16),
        _SkillsCard(skills: applicant.skills),
      ],
    );
  }

  Widget _buildFooter(Applicant applicant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NodoColors.surface,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isUpdating
                    ? null
                    : () => _decide(applicant, ApplicantStatus.rejected),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: NodoColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Rechazar',
                  style: TextStyle(
                    color: NodoColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isUpdating
                    ? null
                    : () => _decide(applicant, ApplicantStatus.accepted),
                style: FilledButton.styleFrom(
                  backgroundColor: NodoColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Aceptar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.applicant});

  final Applicant applicant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          ApplicantAvatar(
            name: applicant.name,
            avatarUrl: applicant.avatarUrl,
            radius: 40,
          ),
          const SizedBox(height: 12),
          Text(
            applicant.name,
            style: const TextStyle(
              color: NodoColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            applicant.program,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: NodoColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            applicant.university,
            style: const TextStyle(
              color: Color(0xFF5B3FA8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.motivation});

  final String motivation;

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
          const Text(
            'MENSAJE DE MOTIVACIÓN',
            style: TextStyle(
              color: NodoColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            motivation,
            style: const TextStyle(
              color: NodoColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatefulWidget {
  const _AttachmentCard({required this.applicant});

  final Applicant applicant;

  @override
  State<_AttachmentCard> createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<_AttachmentCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: Color(0xFFE0533D),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.applicant.attachmentName!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NodoColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.applicant.attachmentSizeLabel != null)
                  Text(
                    widget.applicant.attachmentSizeLabel!,
                    style: const TextStyle(
                      color: NodoColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _saved = !_saved),
            icon: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: NodoColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({required this.skills});

  final List<String> skills;

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
          const Text(
            'HABILIDADES AFINES',
            style: TextStyle(
              color: NodoColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NodoColors.primaryMuted,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: Color(0xFF5B3FA8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
