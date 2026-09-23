import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';

/// Encabezado compartido por las pantallas del feature Applicants:
/// botón de volver circular + título, sobre fondo blanco (Figma HeaderBar).
class ApplicantsScreenHeader extends StatelessWidget {
  const ApplicantsScreenHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NodoColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _BackButton(onPressed: onBack ?? () => Navigator.maybePop(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: NodoColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: NodoColors.surface,
      shape: CircleBorder(
        side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: NodoColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
