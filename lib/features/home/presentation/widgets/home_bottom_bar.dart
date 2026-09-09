import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCreateTap,
  });

  /// 0 = feed, 1 = perfil
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 72,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.only(left: 40, right: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
              color: NodoColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Perfil',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ],
            ),
          ),
          Positioned(bottom: 50, child: _CreateButton(onTap: onCreateTap)),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: NodoColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: NodoColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            icon: Icon(
              icon,
              color: selected ? NodoColors.primary : NodoColors.navInactive,
              size: 28,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
