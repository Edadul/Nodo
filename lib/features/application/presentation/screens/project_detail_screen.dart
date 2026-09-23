import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/application.dart';
import '../../domain/usecases/get_my_application.dart';
import 'application_form_screen.dart';
import 'project_detail_admin_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key, required this.idea});

  final Idea idea;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Future<Application?>? _myApplication;
  String? _loadedForUserId;

  Idea get idea => widget.idea;

  List<Color> get _gradientColors =>
      idea.gradientColors.map(Color.new).toList(growable: false);

  /// Consulta (una vez por usuario) si ya se postuló a este proyecto.
  Future<Application?>? _applicationFor(User user) {
    if (_loadedForUserId != user.id) {
      _loadedForUserId = user.id;
      _myApplication = context
          .read<GetMyApplication?>()
          ?.call(projectId: idea.id, user: user);
    }
    return _myApplication;
  }

  void _reloadApplication() {
    setState(() => _loadedForUserId = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NodoColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildBody(context),
                    ),
                  ],
                ),
              ),
            ),
            _buildPostulateBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 18),
      alignment: Alignment.bottomLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              idea.category,
              style: const TextStyle(
                color: NodoColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          idea.title,
          style: const TextStyle(
            color: NodoColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          idea.description,
          style: const TextStyle(
            color: NodoColors.textSecondary,
            fontSize: 15.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Habilidades requeridas',
          style: TextStyle(
            color: NodoColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: idea.skills
              .map(
                (skill) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: NodoColors.primaryMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      color: NodoColors.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: NodoColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.group_outlined,
                size: 20,
                color: NodoColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                idea.spotsLabel,
                style: const TextStyle(
                  color: NodoColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostulateBar(BuildContext context) {
    final user = context.watch<AuthViewModel?>()?.signedInUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: NodoColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: _buildAction(context, user),
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, User? user) {
    if (user == null) {
      return _actionButton(
        label: 'Inicia sesión para postularte',
        icon: Icons.login_rounded,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          if (mounted) _reloadApplication();
        },
      );
    }

    if (idea.isCreatedBy(user.id)) {
      return _actionButton(
        label: 'Administrar proyecto',
        icon: Icons.shield_outlined,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailAdminScreen(idea: idea),
          ),
        ),
      );
    }

    return FutureBuilder<Application?>(
      future: _applicationFor(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _actionButton(label: 'Verificando…', loading: true);
        }

        final application = snapshot.data;
        if (application != null) {
          return _actionButton(label: _statusLabel(application.status));
        }
        if (idea.isFull) {
          return _actionButton(label: 'Sin cupos disponibles');
        }
        return _actionButton(
          label: 'Postularme',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ApplicationFormScreen(idea: idea),
              ),
            );
            if (mounted) _reloadApplication();
          },
        );
      },
    );
  }

  String _statusLabel(ApplicantStatus status) {
    switch (status) {
      case ApplicantStatus.pending:
        return 'Postulación enviada · Pendiente';
      case ApplicantStatus.accepted:
        return 'Ya eres parte del equipo';
      case ApplicantStatus.rejected:
        return 'Postulación no aceptada';
    }
  }

  /// Botón principal. Sin [onPressed] queda deshabilitado (estado informativo).
  Widget _actionButton({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool loading = false,
  }) {
    final text = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          );

    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
      label: text,
      style: FilledButton.styleFrom(
        backgroundColor: NodoColors.primary,
        disabledBackgroundColor: NodoColors.primaryMuted,
        disabledForegroundColor: NodoColors.primaryDark,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
