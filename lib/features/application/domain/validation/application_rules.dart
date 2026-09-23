import '../../../../core/services/catalog_service.dart';

enum ApplicationField { motivation, skills, experience }

abstract final class ApplicationRules {
  static const motivationMin = 20;
  static const motivationMax = 1000;
  static const skillsMax = 8;

  static const experienceLevels = [
    'Sin experiencia previa',
    'Menos de 1 año',
    '1 a 2 años',
    'Más de 2 años',
  ];
}

String? validateMotivation(String motivation) {
  final text = motivation.trim();
  if (text.length < ApplicationRules.motivationMin) {
    return 'Escribe al menos ${ApplicationRules.motivationMin} caracteres';
  }
  if (text.length > ApplicationRules.motivationMax) {
    return 'Máximo ${ApplicationRules.motivationMax} caracteres';
  }
  return null;
}

String? validateApplicationSkills(List<String> skills) {
  final normalized = skills.map(CatalogService.normalize).toSet();
  if (normalized.isEmpty) return 'Selecciona al menos una habilidad';
  if (normalized.length > ApplicationRules.skillsMax) {
    return 'Selecciona como máximo ${ApplicationRules.skillsMax} habilidades';
  }
  for (final skill in normalized) {
    final error = CatalogService.validateName(skill);
    if (error != null) return '"$skill": $error';
  }
  return null;
}

String? validateExperience(String? experience) {
  return ApplicationRules.experienceLevels.contains(experience)
      ? null
      : 'Selecciona tu experiencia';
}

/// Reglas puras del formulario de postulación. Un mensaje por campo inválido.
Map<ApplicationField, String> validateApplicationForm({
  required String motivation,
  required List<String> skills,
  required String experience,
}) {
  return {
    ApplicationField.motivation: ?validateMotivation(motivation),
    ApplicationField.skills: ?validateApplicationSkills(skills),
    ApplicationField.experience: ?validateExperience(experience),
  };
}
