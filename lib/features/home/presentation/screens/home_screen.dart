import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './profile_screen.dart';
import '../../../../core/config/app_flags.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../../../application/presentation/screens/project_detail_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../project_creation/presentation/screens/create_project_screen.dart';
import '../../domain/entities/idea.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/category_filter.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/idea_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.viewModel});

  final HomeViewModel? viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  late final bool _ownsViewModel;
  late final TextEditingController _searchCtrl;
  AuthViewModel? _auth;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? context.read<HomeViewModel Function()>()();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.load();
    _searchCtrl = TextEditingController();

    _auth = context.read<AuthViewModel?>();
    _auth?.addListener(_onAuthChanged);
    _auth?.loadCurrentUser();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _auth?.removeListener(_onAuthChanged);
    _searchCtrl.dispose();
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: NodoColors.primaryDark,
      ),
    );
  }

  Future<void> _onNavTap(int index) async {
    _viewModel.selectNav(index);
    if (index != 1) return;
    await _openProfileOrLogin();
    if (mounted) _viewModel.selectNav(0);
  }

  Future<void> _openProfileOrLogin() async {
    final auth = _auth;
    final Widget destination = (auth == null || auth.isPublicSession)
        ? const LoginScreen()
        : const ProfileView();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
    if (mounted && destination is ProfileView) _viewModel.load();
  }

  Future<void> _onCreateTap() async {
    if (_auth?.isPublicSession ?? true) {
      _showMessage('Inicia sesión para crear un proyecto');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted || (_auth?.isPublicSession ?? true)) return;
    }

    final created = await Navigator.push<Idea>(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );
    if (!mounted || created == null) return;
    _showMessage('Proyecto "${created.title}" publicado');
    _viewModel.load();
  }

  void _openNotifications() {
    final previewItems = kUiPreviewMode
        ? const [
            (
              'Nueva postulación',
              'Luis Pérez quiere unirse a Huerta urbana',
            ),
            (
              'Avance publicado',
              'Primera siembra lista en tu proyecto',
            ),
            (
              'Cupo ocupado',
              'María Gómez fue aceptada en Huerta urbana',
            ),
          ]
        : const <(String, String)>[];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: NodoColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NodoColors.chipBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bandeja de notificaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (previewItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Aquí verás nuevas postulaciones a tus proyectos y avances del equipo. Por ahora no tienes avisos pendientes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: NodoColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  ...previewItems.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: NodoColors.primaryMuted,
                        child: Icon(
                          Icons.notifications_rounded,
                          color: NodoColors.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        item.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(item.$2),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: NodoColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;

    return Scaffold(
      backgroundColor: NodoColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nodo',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: NodoColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Proyectos del campus para unirte o crear el tuyo',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: NodoColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openNotifications,
                    tooltip: 'Notificaciones',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: NodoColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: vm.setSearchQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar por título, habilidad…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: vm.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            vm.clearSearch();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: NodoColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (vm.categories.isNotEmpty)
              CategoryFilter(
                categories: vm.categories,
                selected: vm.selectedCategory,
                onSelected: vm.selectCategory,
              ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(
        currentIndex: vm.navIndex,
        onTap: _onNavTap,
        onCreateTap: _onCreateTap,
      ),
    );
  }

  Widget _buildBody(HomeViewModel vm) {
    if (vm.status == HomeStatus.loading || vm.status == HomeStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: NodoColors.primary),
      );
    }

    if (vm.status == HomeStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.errorMessage ?? 'Error al cargar ideas',
                textAlign: TextAlign.center,
                style: const TextStyle(color: NodoColors.textSecondary),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: vm.load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    if (vm.ideas.isEmpty) {
      return RefreshIndicator(
        color: NodoColors.primary,
        onRefresh: () => vm.load(silent: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(
              vm.searchQuery.isEmpty
                  ? Icons.inbox_outlined
                  : Icons.search_off_rounded,
              size: 40,
              color: NodoColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              vm.searchQuery.isEmpty
                  ? 'Aún no hay proyectos aquí.\nCrea uno con el botón + o cambia de categoría.'
                  : 'Sin resultados para “${vm.searchQuery.trim()}”',
              textAlign: TextAlign.center,
              style: const TextStyle(color: NodoColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: NodoColors.primary,
      onRefresh: () => vm.load(silent: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: vm.ideas.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final idea = vm.ideas[index];
          return IdeaCard(
            idea: idea,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(idea: idea),
                ),
              );
              if (mounted) vm.load(silent: true);
            },
          );
        },
      ),
    );
  }
}
