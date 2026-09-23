import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/domain/entities/user.dart';

import '../../domain/usecases/get_ideas.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../../../applicants/presentation/screens/applicants_list_screen.dart';
import '../../../application/presentation/screens/project_detail_admin_screen.dart';
import '../../../project_creation/presentation/screens/create_project_screen.dart';
import '../../data/mock_profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/entities/idea.dart';
import '../../domain/entities/profile.dart';

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
  bool _isLoadingProjects = true;

  Profile? _profile;
  bool _isPublicSession = true;
  bool _isLoadingProfile = true;

  AuthViewModel? get _auth => context.read<AuthViewModel?>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// El perfil primero: los proyectos se filtran con el usuario de la sesión.
  Future<void> _load() async {
    await _loadUserProfile();
    await _loadMyProjects();
  }

  Future<void> _loadMyProjects() async {
    final creatorId = _auth?.signedInUser?.id;
    // En sesión pública nadie es dueño de nada: no hay proyectos que
    // administrar.
    if (creatorId == null) {
      if (mounted) setState(() => _isLoadingProjects = false);
      return;
    }

    try {
      final ideas = await context.read<GetIdeas>()();
      if (mounted) {
        // `projects.creator_id` → `users.id` → el mismo id de la sesión.
        final myProjects = ideas
            .where((idea) => idea.isCreatedBy(creatorId))
            .toList(growable: false);
        setState(() {
          _myProjects = myProjects;
          _isLoadingProjects = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
        });
      }
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailAdminScreen(idea: idea),
      ),
    );
    if (mounted) _loadMyProjects();
  }

  Future<void> _openApplicants(Idea idea) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicantsListScreen(projectId: idea.id),
      ),
    );
    // Aceptar postulaciones cambia los cupos ocupados.
    if (mounted) _loadMyProjects();
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
      // Mientras se carga el perfil real no enseñamos la cuenda de ejemplo ni
      // la mock: mostramos una pantalla de carga para que no «parpadee»
      // durante un instante tras iniciar sesión.
      return const _ProfileLoadingView();
    }

    final profile = _profile ?? profile1;

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
          'Mi Perfil',
          style: TextStyle(
            color: NodoColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajustes del perfil')),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: NodoColors.textPrimary,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: 20),
          _buildStatsRow(profile),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
          _buildTabSelector(),
          const SizedBox(height: 16),
          if (_selectedTab == 0)
            _buildProjectsSection()
          else
            _buildSettingsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [NodoColors.primarySoft, NodoColors.primary],
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: NodoColors.primaryMuted,
                  child: ClipOval(
                    child: Image.network(
                      profile.avatar,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_rounded,
                        size: 55,
                        color: NodoColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: NodoColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
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
          const SizedBox(height: 4),
          Text(
            '${profile.username} • Creador de Proyectos',
            style: const TextStyle(
              fontSize: 13,
              color: NodoColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: NodoColors.primaryMuted.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.bio,
              style: const TextStyle(
                color: NodoColors.primaryDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Profile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: NodoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NodoColors.chipBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // «Proyectos» es el recuento real de las ideas del usuario que ya
          // calculamos en `_loadMyProjects` (filtradas por creator_id), no la
          // columna estática posts_count de `users` (que suele venir a 0).
          _buildStatColumn('${_myProjects.length}', 'Proyectos'),
          Container(height: 28, width: 1, color: NodoColors.chipBorder),
          _buildStatColumn('${profile.followers}', 'Postulaciones'),
          Container(height: 28, width: 1, color: NodoColors.chipBorder),
          _buildStatColumn('${profile.favorites}', 'Colaboraciones'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: NodoColors.primaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: NodoColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editar perfil próximamente')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: NodoColors.primaryMuted,
                  foregroundColor: NodoColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Editar Perfil',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enlace de perfil copiado')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: NodoColors.textPrimary,
                  side: const BorderSide(color: NodoColors.chipBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Compartir',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isPublicSession) ...[
          SizedBox(
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
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _logout,
              style: FilledButton.styleFrom(
                backgroundColor: NodoColors.primaryMuted,
                foregroundColor: NodoColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
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
          Expanded(
            child: _tabButton('Mis Proyectos', 0),
          ),
          Expanded(
            child: _tabButton('Preferencias', 1),
          ),
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
                    Text(
                      idea.spotsLabel,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: NodoColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FilledButton(
                      onPressed: () => _openAdminDetail(idea),
                      style: FilledButton.styleFrom(
                        backgroundColor: NodoColors.primary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
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
    return Card(
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
          ListTile(
            leading: const Icon(
              Icons.security_rounded,
              color: NodoColors.textPrimary,
            ),
            title: const Text('Seguridad de la Cuenta'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_active_rounded,
              color: NodoColors.textPrimary,
            ),
            title: const Text('Notificaciones de Postulaciones'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(
              Icons.palette_rounded,
              color: NodoColors.textPrimary,
            ),
            title: const Text('Tema y Apariencia'),
            subtitle: const Text('Material 3'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(
              Icons.help_outline_rounded,
              color: NodoColors.textPrimary,
            ),
            title: const Text('Ayuda y Soporte'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
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
