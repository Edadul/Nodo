import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../../applicants/domain/entities/team_member.dart';
import '../../../applicants/domain/usecases/get_project_team.dart';
import '../../../applicants/presentation/screens/applicants_list_screen.dart';
import '../../../applicants/presentation/widgets/project_team_section.dart';
import '../../../home/domain/entities/idea.dart';
import '../../../projects/domain/entities/project_status.dart';
import '../../../projects/domain/entities/project_update.dart';
import '../../../projects/domain/usecases/get_project_updates.dart';
import '../../../projects/domain/usecases/update_project_details.dart';
import '../../../projects/domain/usecases/update_project_status.dart';
import '../../../projects/presentation/screens/publish_update_screen.dart';
import '../../../projects/presentation/widgets/project_updates_timeline.dart';

class ProjectDetailAdminScreen extends StatefulWidget {
  const ProjectDetailAdminScreen({super.key, required this.idea});

  final Idea idea;

  @override
  State<ProjectDetailAdminScreen> createState() =>
      _ProjectDetailAdminScreenState();
}

class _ProjectDetailAdminScreenState extends State<ProjectDetailAdminScreen> {
  late Idea _idea;
  bool _savingStatus = false;
  Future<List<TeamMember>>? _team;
  Future<List<ProjectUpdate>>? _updates;

  @override
  void initState() {
    super.initState();
    _idea = widget.idea;
    _loadTeam();
    _loadUpdates();
  }

  List<Color> get _gradientColors =>
      _idea.gradientColors.map(Color.new).toList(growable: false);

  void _loadTeam() {
    try {
      _team = context.read<GetProjectTeam>()(_idea.id).then((t) => t.members);
    } catch (_) {
      _team = Future.value(const <TeamMember>[]);
    }
  }

  void _loadUpdates() {
    try {
      _updates = context.read<GetProjectUpdates>().call(_idea.id);
    } catch (_) {
      _updates = Future.value(const <ProjectUpdate>[]);
    }
  }

  Future<void> _openPublishUpdate() async {
    final update = await Navigator.push<ProjectUpdate>(
      context,
      MaterialPageRoute(
        builder: (_) => PublishUpdateScreen(
          idea: _idea,
          allowStatusChange: true,
        ),
      ),
    );
    if (!mounted || update == null) return;
    setState(() {
      if (update.status != null) {
        _idea = _idea.copyWith(status: update.status);
      }
      _loadUpdates();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avance publicado')),
    );
  }

  Future<void> _navigateToApplicants() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicantsListScreen(projectId: _idea.id),
      ),
    );
    if (!mounted) return;
    // Tras aceptar/rechazar, cupos y equipo pueden cambiar.
    try {
      final team = await context.read<GetProjectTeam>()(_idea.id);
      if (!mounted) return;
      setState(() {
        _idea = team.project;
        _team = Future.value(team.members);
      });
    } catch (_) {
      if (mounted) setState(_loadTeam);
    }
  }

  Future<void> _setStatus(ProjectStatus status) async {
    if (status == _idea.status || _idea.recordId.isEmpty) {
      setState(() => _idea = _idea.copyWith(status: status));
      return;
    }

    setState(() {
      _savingStatus = true;
      _idea = _idea.copyWith(status: status);
    });

    try {
      await context.read<UpdateProjectStatus>()(
        projectRecordId: _idea.recordId,
        status: status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a ${status.label}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el estado')),
      );
    } finally {
      if (mounted) setState(() => _savingStatus = false);
    }
  }

  Future<void> _editProject() async {
    final titleCtrl = TextEditingController(text: _idea.title);
    final descCtrl = TextEditingController(text: _idea.description);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar proyecto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (saved != true || !mounted) {
      titleCtrl.dispose();
      descCtrl.dispose();
      return;
    }

    final title = titleCtrl.text.trim();
    final description = descCtrl.text.trim();
    titleCtrl.dispose();
    descCtrl.dispose();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y descripción son obligatorios')),
      );
      return;
    }

    if (_idea.recordId.isEmpty) {
      setState(() => _idea = _idea.copyWith(title: title, description: description));
      return;
    }

    try {
      await context.read<UpdateProjectDetails>()(
        projectRecordId: _idea.recordId,
        title: title,
        description: description,
      );
      if (!mounted) return;
      setState(
        () => _idea = _idea.copyWith(title: title, description: description),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto actualizado')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el proyecto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pop(context, _idea);
      },
      child: Scaffold(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado del proyecto',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NodoColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStageSelector(),
                            if (_savingStatus) ...[
                              const SizedBox(height: 8),
                              const LinearProgressIndicator(minHeight: 2),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              _idea.status.subtitle,
                              style: const TextStyle(
                                color: NodoColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildProjectInfo(),
                            const SizedBox(height: 24),
                            _buildTeamAdminCard(),
                            const SizedBox(height: 24),
                            _buildSkillsSection(),
                            const SizedBox(height: 28),
                            _buildUpdatesSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomAdminBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context, _idea),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Modo Creador',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _idea.category,
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
        ],
      ),
    );
  }

  Widget _buildStageSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: NodoColors.chipInactive,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _stageChip(ProjectStatus.idea),
          _stageChip(ProjectStatus.inProgress),
          _stageChip(ProjectStatus.closed),
        ],
      ),
    );
  }

  Widget _stageChip(ProjectStatus status) {
    final isSelected = _idea.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: _savingStatus ? null : () => _setStatus(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? NodoColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            status.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? NodoColors.primary : NodoColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _idea.title,
          style: const TextStyle(
            color: NodoColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _idea.description,
          style: const TextStyle(
            color: NodoColors.textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamAdminCard() {
    final filled = _idea.filledSpots;
    final total = _idea.totalSpots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NodoColors.chipBorder.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? (filled / total).clamp(0.0, 1.0) : 0,
              minHeight: 8,
              backgroundColor: NodoColors.chipInactive,
              color: NodoColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<TeamMember>>(
            future: _team,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ProjectTeamSection(
                members: snapshot.data ?? const [],
                spotsLabel: '$filled de $total cupos',
                compact: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    if (_idea.skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habilidades buscadas',
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
          children: _idea.skills
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
      ],
    );
  }

  Widget _buildUpdatesSection() {
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
            TextButton.icon(
              onPressed: _openPublishUpdate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Publicar'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Cuenta al equipo y a quienes visitan el proyecto qué está pasando.',
          style: TextStyle(
            color: NodoColors.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
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
              emptyMessage:
                  'Todavía no hay avances. Publica el primero para que el equipo se entere.',
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomAdminBar(BuildContext context) {
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _editProject,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NodoColors.textPrimary,
                  side: const BorderSide(color: NodoColors.chipBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openPublishUpdate,
                icon: const Icon(Icons.campaign_outlined, size: 18),
                label: const Text('Avance'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: NodoColors.primaryDark,
                  side: const BorderSide(color: NodoColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _navigateToApplicants,
                icon: const Icon(Icons.inbox_rounded, size: 18),
                label: const Text(
                  'Postulaciones',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: NodoColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
