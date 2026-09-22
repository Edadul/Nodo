import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/usecases/get_ideas.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../../../applicants/presentation/screens/applicants_list_screen.dart';
import '../../../application/presentation/screens/project_detail_admin_screen.dart';
import '../../data/mock_profile.dart';
import '../../domain/entities/idea.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMyProjects();
  }

  Future<void> _loadMyProjects() async {
    try {
      final ideas = await context.read<GetIdeas>()();
      if (mounted) {
        setState(() {
          _myProjects = ideas.take(3).toList();
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

  void _openAdminDetail(Idea idea) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailAdminScreen(idea: idea),
      ),
    );
  }

  void _openApplicants(Idea idea) {
    final projectId = int.tryParse(idea.id) ?? 1;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicantsListScreen(projectId: projectId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = profile1;

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
          _buildStatsRow(),
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

  Widget _buildStatsRow() {
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
          _buildStatColumn('${_myProjects.length}', 'Proyectos'),
          Container(height: 28, width: 1, color: NodoColors.chipBorder),
          _buildStatColumn('8', 'Postulaciones'),
          Container(height: 28, width: 1, color: NodoColors.chipBorder),
          _buildStatColumn('3', 'Colaboraciones'),
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
    return Row(
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
              const Text(
                'Aún no has creado ningún proyecto',
                style: TextStyle(
                  color: NodoColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Crear proyecto')),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Crear Proyecto'),
              ),
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
                                child: const Text(
                                  'En desarrollo',
                                  style: TextStyle(
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
