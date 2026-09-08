import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/category_filter.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/idea_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.viewModel});

  /// Permite inyectar un ViewModel en tests.
  final HomeViewModel? viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel =
        widget.viewModel ?? ServiceLocator.instance.createHomeViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.load();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
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

  void _onNavTap(int index) {
    _viewModel.selectNav(index);
    if (index == 1) {
      _showMessage('Perfil (próximamente)');
    }
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
                          'Únete',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: NodoColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Explora ideas en crecimiento o siembra la tuya',
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
                    onPressed: () =>
                        _showMessage('Notificaciones (próximamente)'),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: NodoColors.textPrimary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: GestureDetector(
                      onTap: () {
                        _viewModel.selectNav(1);
                        _showMessage('Perfil (próximamente)');
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: NodoColors.primaryMuted,
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: NodoColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (vm.categories.isNotEmpty)
              CategoryFilter(
                categories: vm.categories,
                selected: vm.selectedCategory,
                onSelected: vm.selectCategory,
              ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(
        currentIndex: vm.navIndex,
        onTap: _onNavTap,
        onCreateTap: () => _showMessage('Crear nueva idea (próximamente)'),
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
              FilledButton(
                onPressed: vm.load,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.ideas.isEmpty) {
      return const Center(
        child: Text(
          'No hay ideas en esta categoría',
          style: TextStyle(color: NodoColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: vm.ideas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final idea = vm.ideas[index];
        return IdeaCard(
          idea: idea,
          onTap: () => showIdeaPreview(context, idea),
        );
      },
    );
  }
}
