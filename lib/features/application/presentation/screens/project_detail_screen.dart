import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../applicants/domain/entities/team_member.dart';
import '../../../applicants/domain/usecases/get_project_team.dart';
import '../../../applicants/presentation/widgets/project_team_section.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../home/domain/entities/idea.dart';
import '../../../projects/domain/entities/project_update.dart';
import '../../../projects/domain/usecases/get_project_updates.dart';
import '../../../projects/presentation/screens/publish_update_screen.dart';
import '../../../projects/presentation/widgets/project_status_badge.dart';
import '../../../projects/presentation/widgets/project_updates_timeline.dart';
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
  Future<List<ProjectUpdate>>? _updates;
  Future<List<TeamMember>>? _team;
  String? _loadedForUserId;
  late Idea _idea;

  @override
  void initState() {
    super.initState();
    _idea = widget.idea;
    _loadUpdates();
    _loadTeam();
  }

  Idea get idea => _idea;

  List<Color> get _gradientColors =>
      idea.gradientColors.map(Color.new).toList(growable: false);

  void _loadUpdates() {
    try {
      _updates = context.read<GetProjectUpdates>().call(idea.id);
    } catch (_) {
      _updates = Future.value(const <ProjectUpdate>[]);
    }
  }

  void _loadTeam() {
    try {
      _team = context.read<GetProjectTeam>()(idea.id).then((t) => t.members);
    } catch (_) {
      _team = Future.value(const <TeamMember>[]);
    }
  }

  Future<Application?>? _applicationFor(User user) {
    if (_loadedForUserId != user.id) {
      _loadedForUserId = user.id;
      try {
        _myApplication = context.read<GetMyApplication>().call(
              projectId: idea.id,
              user: user,
            );
      } catch (_) {
        _myApplication = Future.value(null);
      }
    }
    return _myApplication;
  }

  void _reloadApplication() {
    setState(() => _loadedForUserId = null);
  }

  Future<void> _openPublishUpdate({required bool allowStatusChange}) async {
    final update = await Navigator.push<ProjectUpdate>(
      context,
      MaterialPageRoute(
        builder: (_) => PublishUpdateScreen(
          idea: idea,
          allowStatusChange: allowStatusChange,
        ),
      ),
    );
    if (!mounted || update == null) return;
    setState(() {
      if (update.status != null) {
        _idea = _idea.copyWith(status: update.status);
      }
      _loadUpdates();
      _loadTeam();
    });
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
    final user = context.watch<AuthViewModel?>()?.signedInUser;
    final isOwner = user != null && idea.isCreatedBy(user.id);
    final myApp = user == null ? null : _applicationFor(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProjectStatusBadge(status: idea.status),
            const SizedBox(width: 10),
            Text(
              idea.status.subtitle,
              style: const TextStyle(
                color: NodoColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
        const SizedBox(height: 28),
        FutureBuilder<List<TeamMember>>(
          future: _team,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ProjectTeamSection(
              members: snapshot.data ?? const [],
              spotsLabel: idea.spotsLabel,
            );
          },
        ),
        const SizedBox(height: 28),
        FutureBuilder<Application?>(
          future: myApp,
          builder: (context, appSnap) {
            final isMember =
                isOwner || appSnap.data?.status == ApplicantStatus.accepted;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Avances del proyecto',
                        style: TextStyle(
                          color: NodoColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isMember)
                      TextButton.icon(
                        onPressed: () => _openPublishUpdate(
                          allowStatusChange: isOwner,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Publicar'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<ProjectUpdate>>(
                  future: _updates,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return ProjectUpdatesTimeline(
                      updates: snapshot.data ?? const [],
                    );
                  },
                ),
              ],
            );
          },
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
        label: 'Gestionar equipo y estado',
        icon: Icons.tune_rounded,
        onPressed: () async {
          final updated = await Navigator.push<Idea>(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailAdminScreen(idea: idea),
            ),
          );
          if (!mounted || updated == null) return;
          setState(() {
            _idea = updated;
            _loadUpdates();
          });
        },
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
          if (application.status == ApplicantStatus.accepted) {
            return _actionButton(
              label: 'Publicar avance del equipo',
              icon: Icons.campaign_outlined,
              onPressed: () => _openPublishUpdate(allowStatusChange: false),
            );
          }
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

  Widget _actionButton({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool loading = false,
  }) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          );

    final style = FilledButton.styleFrom(
      backgroundColor: NodoColors.primary,
      disabledBackgroundColor: NodoColors.primaryMuted,
      disabledForegroundColor: NodoColors.primaryDark,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );

    if (icon == null || loading) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: child,
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: child,
      style: style,
    );
  }
}
