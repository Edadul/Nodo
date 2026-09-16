import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/application.dart';

class ApplicationConfirmationScreen extends StatelessWidget {
  const ApplicationConfirmationScreen({
    super.key,
    required this.idea,
    required this.application,
  });

  final Idea idea;
  final Application application;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NodoColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: NodoColors.primaryMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: NodoColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '¡Postulación enviada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NodoColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu solicitud para unirte a "${idea.title}" fue enviada. '
                'El líder del proyecto revisará tu postulación y te avisará '
                'cuando la apruebe.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: NodoColors.textSecondary,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: NodoColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}