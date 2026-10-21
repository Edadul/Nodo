import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/db/db_interface.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../applicants/presentation/screens/applicants_list_screen.dart';
import '../../../applicants/presentation/widgets/applicant_status_badge.dart';
import '../../../application/domain/entities/project_participation.dart';
import '../../../application/domain/usecases/get_my_participations.dart';
import '../../../application/presentation/screens/project_detail_admin_screen.dart';
import '../../../application/presentation/screens/project_detail_screen.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../project_creation/presentation/screens/create_project_screen.dart';
import '../../../projects/domain/entities/project_update.dart';
import '../../../projects/presentation/screens/publish_update_screen.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_ideas.dart';

typedef ProfileScreen = ProfileView;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedTab = 0;
  bool _notificationsEnabled = true;
  List<Idea> _myProjects = [];
  List<ProjectParticipation> _participations = [];
  bool _isLoadingProjects = true;

  Profile? _profile;
  bool _isPublicSession = true;
  bool _isLoadingProfile = true;

  AuthViewModel? get _auth => context.read<AuthViewModel?>();

  int get _joinedCount =>
      _participations.where((p) => p.isMember).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// El perfil primero: luego proyectos creados y postulaciones del usuario.
  Future<void> _load() async {
    await _loadUserProfile();
    await Future.wait([_loadMyProjects(), _loadParticipations()]);
  }

  Future<void> _loadMyProjects() async {
    final creatorId = _auth?.signedInUser?.id;
    if (creatorId == null) {
      if (mounted) {
        setState(() {
          _myProjects = [];
          _isLoadingProjects = false;
        });
      }
      return;
    }

    try {
      final ideas = await context.read<GetIdeas>()();
      if (!mounted) return;
      setState(() {
        _myProjects = ideas
            .where((idea) => idea.isCreatedBy(creatorId))
            .toList(growable: false);
        _isLoadingProjects = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingProjects = false);
    }
  }

  Future<void> _loadParticipations() async {
    final user = _auth?.signedInUser;
    if (user == null) {
      if (mounted) setState(() => _participations = []);
      return;
    }

    try {
      final items = await context.read<GetMyParticipations>()(user);
      if (mounted) setState(() => _participations = items);
    } catch (_) {
      if (mounted) setState(() => _participations = []);
    }
  }

  /// Construye un [Profile] con la información que ya trae la sesión
  /// autenticada (nombre, correo, avatar), sin depender de que exista una fila
  /// en la tabla `users`. Así el nombre real siempre se ve.
  Profile _profileFromUser(User user) {
    final username = user.email.split('@').first;
    return Profile(
      name: user.name,
      username: username.startsWith('@') ? username : '@$username',
      bio: user.name,
      avatar: user.avatarUrl,
      posts: 0,
      followers: 0,
      favorites: 0,
    );
  }

  Future<void> _loadUserProfile() async {
    final auth = _auth;
    if (auth == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    if (auth.currentUser == null) {
      await auth.loadCurrentUser();
    }

    if (!mounted) return;

    Profile? profile;
    if (auth.currentUser != null) {
      final repository = context.read<ProfileRepository?>();
      profile = await repository?.fetchByUserId(auth.currentUser!.id);

      // Si la tabla `users` aún no tiene fila (o no es legible para esta
      // cuenta), no mostramos el perfil de ejemplo: usamos los datos reales
      // que ya trae la sesión autenticada (nombre, correo, avatar).
      profile ??= _profileFromUser(auth.currentUser!);
    }

    if (mounted) {
      setState(() {
        _profile = profile;
        _isPublicSession = auth.isPublicSession;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    final auth = _auth;
    if (auth == null) return;
    await auth.logout();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _openAdminDetail(Idea idea) async {
    final updated = await Navigator.push<Idea>(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailAdminScreen(idea: idea),
      ),
    );
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        _myProjects = [
          for (final p in _myProjects) p.id == updated.id ? updated : p,
        ];
      });
    }
    await Future.wait([_loadMyProjects(), _loadParticipations()]);
  }

  Future<void> _openApplicants(Idea idea) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicantsListScreen(projectId: idea.id),
      ),
    );
    if (mounted) {
      await Future.wait([_loadMyProjects(), _loadParticipations()]);
    }
  }

  Future<void> _openJoinedProject(ProjectParticipation participation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(idea: participation.project),
      ),
    );
    if (mounted) await _loadParticipations();
  }

  Future<void> _openPublishUpdate(
    Idea idea, {
    bool allowStatusChange = true,
  }) async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avance publicado')),
    );
    if (update.status != null) {
      setState(() {
        _myProjects = [
          for (final p in _myProjects)
            p.id == idea.id ? p.copyWith(status: update.status) : p,
        ];
      });
    }
  }

  Future<void> _openCreateProject() async {
    final created = await Navigator.push<Idea>(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );
    if (!mounted || created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proyecto "${created.title}" publicado')),
    );
    setState(() => _isLoadingProjects = true);
    await _loadMyProjects();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const _ProfileLoadingView();
    }

    final profile = _profile ??
        const Profile(
          name: 'Invitado',
          username: '@invitado',
          bio: 'Explora proyectos o inicia sesión',
          avatar: '',
          posts: 0,
          followers: 0,
          favorites: 0,
        );

    return Scaffold(
      backgroundColor: NodoColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: NodoColors.textPrimary,
          ),
        ),
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: NodoColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 20),
          _buildTabSelector(),
          const SizedBox(height: 16),
          if (_selectedTab == 0)
            _buildProjectsSection()
          else if (_selectedTab == 1)
            _buildJoinedSection()
          else
            _buildSettingsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Profile profile) {
    final email = _auth?.signedInUser?.email ?? '';
    final bio = profile.bio.trim();
    final showBio =
        bio.isNotEmpty && bio.toLowerCase() != profile.name.toLowerCase();

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isPublicSession ? null : _editProfile,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [NodoColors.primarySoft, NodoColors.primary],
                ),
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: NodoColors.primaryMuted,
                child: ClipOval(
                  child: Image.network(
                    profile.avatar,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person_rounded,
                      size: 52,
                      color: NodoColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: NodoColors.textPrimary,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 13,
                color: NodoColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (!_isLoadingProjects && !_isPublicSession) ...[
            const SizedBox(height: 8),
            Text(
              '${_myProjects.length} creados · $_joinedCount en equipo'
              '${_participations.length > _joinedCount ? ' · ${_participations.length - _joinedCount} en revisión' : ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: NodoColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (showBio) ...[
            const SizedBox(height: 10),
            Text(
              bio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: NodoColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final edited = await showDialog<({String name, String bio})>(
      context: context,
      builder: (_) => _EditProfileDialog(name: profile.name, bio: profile.bio),
    );
    if (edited == null || !mounted) return;
    final name = edited.name.trim();
    final bio = edited.bio.trim();
    if (name.isEmpty) return;

    final userId = _auth?.signedInUser?.id;
    if (userId != null) {
      try {
        final db = context.read<IDatabase>();
        final rows = await db.read('users', filters: {'id': userId});
        if (rows.isNotEmpty) {
          final recordId = rows.first['_id']?.toString() ?? '';
          if (recordId.isNotEmpty) {
            await db.update('users', recordId, {
              'name': name,
              'bio': bio,
            });
          }
        }
      } catch (_) {
        // Si Roble no permite update, igual actualizamos la UI local.
      }
    }

    setState(() {
      _profile = Profile(
        name: name,
        username: profile.username,
        bio: bio.isEmpty ? profile.bio : bio,
        avatar: profile.avatar,
        posts: profile.posts,
        followers: profile.followers,
        favorites: profile.favorites,
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  void _showInfoSheet({
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NodoColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    color: NodoColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: NodoColors.primary,
                    ),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    if (_isPublicSession) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: NodoColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.login_rounded, size: 18),
          label: const Text(
            'Iniciar sesión',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _editProfile,
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text(
          'Editar perfil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: NodoColors.textPrimary,
          side: const BorderSide(color: NodoColors.chipBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: NodoColors.chipInactive,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(child: _tabButton('Creados', 0)),
          Expanded(child: _tabButton('Unidos', 1)),
          Expanded(child: _tabButton('Cuenta', 2)),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? NodoColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? NodoColors.primary : NodoColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildJoinedSection() {
    if (_isLoadingProjects) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: NodoColors.primary),
        ),
      );
    }

    if (_isPublicSession) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Inicia sesión para ver los proyectos a los que te postulas o ya te uniste.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: NodoColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_participations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 48,
              color: NodoColors.navInactive,
            ),
            SizedBox(height: 12),
            Text(
              'Aún no te has postulado a ningún proyecto.\nExplora el feed y únete a uno.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NodoColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final item in _participations) ...[
          _buildJoinedCard(item),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildJoinedCard(ProjectParticipation item) {
    final idea = item.project;
    final gradientColors =
        idea.gradientColors.map(Color.new).toList(growable: false);
    final subtitle = switch (item.status) {
      ApplicantStatus.accepted => 'Formas parte del equipo',
      ApplicantStatus.pending => 'Esperando respuesta del creador',
      ApplicantStatus.rejected => 'Postulación no aceptada',
    };

    return Container(
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NodoColors.chipBorder.withValues(alpha: 0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openJoinedProject(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idea.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: NodoColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: NodoColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ApplicantStatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  idea.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: NodoColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (item.isMember) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _openPublishUpdate(
                        idea,
                        allowStatusChange: false,
                      ),
                      icon: const Icon(Icons.campaign_outlined, size: 16),
                      label: const Text(
                        'Publicar avance',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    if (_isLoadingProjects) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: NodoColors.primary),
        ),
      );
    }

    if (_myProjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.folder_open_rounded,
                size: 48,
                color: NodoColors.navInactive,
              ),
              const SizedBox(height: 12),
              Text(
                _isPublicSession
                    ? 'Inicia sesión para crear y administrar proyectos'
                    : 'Aún no has creado ningún proyecto',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: NodoColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isPublicSession) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _openCreateProject,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Crear Proyecto'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final idea in _myProjects) ...[
          _buildProjectCard(idea),
          const SizedBox(height: 14),
        ],
        OutlinedButton.icon(
          onPressed: _openCreateProject,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Crear otro proyecto'),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Idea idea) {
    final gradientColors =
        idea.gradientColors.map(Color.new).toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NodoColors.chipBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openAdminDetail(idea),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: NodoColors.primaryMuted,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  idea.category,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: NodoColors.primaryDark,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: NodoColors.chipInactive,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  idea.isFull
                                      ? 'Cupos completos'
                                      : '${idea.availableSpots} cupos libres',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: NodoColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            idea.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: NodoColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  idea.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: NodoColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: NodoColors.chipInactive),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 16,
                      color: NodoColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        idea.spotsLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: NodoColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openPublishUpdate(idea),
                      icon: const Icon(
                        Icons.campaign_outlined,
                        size: 16,
                        color: NodoColors.primaryDark,
                      ),
                      label: const Text(
                        'Avance',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: NodoColors.primaryDark,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openApplicants(idea),
                      icon: const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 16,
                        color: NodoColors.primary,
                      ),
                      label: const Text(
                        'Postulaciones',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: NodoColors.primary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: NodoColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: NodoColors.chipBorder.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(
                  Icons.notifications_active_rounded,
                  color: NodoColors.textPrimary,
                ),
                title: const Text('Avisos de postulaciones'),
                subtitle: Text(
                  _notificationsEnabled
                      ? 'Activos en este dispositivo'
                      : 'Pausados en este dispositivo',
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Notificaciones activadas'
                            : 'Notificaciones desactivadas',
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(
                  Icons.help_outline_rounded,
                  color: NodoColors.textPrimary,
                ),
                title: const Text('Cómo usar Nodo'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showInfoSheet(
                  title: 'Cómo usar Nodo',
                  body:
                      'Explora y postúlate desde el feed. En Creados gestiona estado, postulaciones y avances. En Unidos ves pendientes y equipos a los que ya perteneces; como integrante también puedes publicar avances.',
                ),
              ),
            ],
          ),
        ),
        if (!_isPublicSession) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: NodoColors.primaryDark,
                side: const BorderSide(color: NodoColors.chipBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Diálogo de edición del perfil. Es dueño de sus controllers y los libera en
/// [State.dispose], cuando la animación de cierre ya terminó: liberarlos al
/// volver de `showDialog` rompe los TextField que aún se están pintando.
class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.name, required this.bio});

  final String name;
  final String bio;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.name);
  late final TextEditingController _bioCtrl =
      TextEditingController(text: widget.bio);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioCtrl,
            decoration: const InputDecoration(labelText: 'Bio'),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            (name: _nameCtrl.text, bio: _bioCtrl.text),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Pantalla de carga del perfil: se enseña durante el instante en que la
/// cuenta real (tabla `users`) aún no ha terminado de cargarse, para que no
/// «parpadee» la cuenta de ejemplo ni la mock tras iniciar sesión.
class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: NodoColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: NodoColors.primary,
        ),
      ),
    );
  }
}
