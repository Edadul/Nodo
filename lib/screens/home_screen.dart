import 'package:flutter/material.dart';

import '../data/mock_ideas.dart';
import '../models/idea.dart';
import '../theme/nodo_theme.dart';
import '../widgets/category_filter.dart';
import '../widgets/home_bottom_bar.dart';
import '../widgets/idea_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'TODAS';
  int _navIndex = 0;

  List<Idea> get _filteredIdeas {
    if (_selectedCategory == 'TODAS') return kMockIdeas;
    return kMockIdeas
        .where((idea) => idea.category == _selectedCategory)
        .toList();
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
    setState(() => _navIndex = index);
    if (index == 1) {
      _showMessage('Perfil (próximamente)');
    }
  }

  void _onCreateTap() {
    _showMessage('Crear nueva idea (próximamente)');
  }

  @override
  Widget build(BuildContext context) {
    final ideas = _filteredIdeas;

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
                        setState(() => _navIndex = 1);
                        _showMessage('Perfil (próximamente)');
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: NodoColors.primaryMuted,
                        child: const Icon(
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
            CategoryFilter(
              categories: kIdeaCategories,
              selected: _selectedCategory,
              onSelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ideas.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay ideas en esta categoría',
                        style: TextStyle(color: NodoColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: ideas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final idea = ideas[index];
                        return IdeaCard(
                          idea: idea,
                          onTap: () => showIdeaPreview(context, idea),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
        onCreateTap: _onCreateTap,
      ),
    );
  }
}
