import '../../../../core/services/catalog_service.dart';
import '../entities/project_draft.dart';

enum ProjectField { title, description, totalSpots, categories, skills }

/// Límites compartidos por la validación y el formulario.
abstract final class ProjectRules {
  static const titleMin = 5;
  static const titleMax = 80;
  static const descriptionMin = 20;
  static const descriptionMax = 1000;
  static const spotsMin = 1;
  static const spotsMax = 20;
  static const categoriesMax = 3;
  static const skillsMax = 8;
  static const tagMax = CatalogService.nameMaxLength;
}

/// Reglas puras (sin red) de un [ProjectDraft]. Devuelve un mensaje por campo
/// inválido; vacío si todo es correcto.
Map<ProjectField, String> validateProjectDraft(ProjectDraft draft) {
  final errors = <ProjectField, String>{};

  final title = draft.title.trim();
  if (title.length < ProjectRules.titleMin) {
    errors[ProjectField.title] =
        'El título debe tener al menos ${ProjectRules.titleMin} caracteres';
  } else if (title.length > ProjectRules.titleMax) {
    errors[ProjectField.title] =
        'El título no puede superar ${ProjectRules.titleMax} caracteres';
  }

  final description = draft.description.trim();
  if (description.length < ProjectRules.descriptionMin) {
    errors[ProjectField.description] = 'Describe el proyecto con al menos '
        '${ProjectRules.descriptionMin} caracteres';
  } else if (description.length > ProjectRules.descriptionMax) {
    errors[ProjectField.description] = 'La descripción no puede superar '
        '${ProjectRules.descriptionMax} caracteres';
  }

  if (draft.totalSpots < ProjectRules.spotsMin ||
      draft.totalSpots > ProjectRules.spotsMax) {
    errors[ProjectField.totalSpots] = 'Los cupos deben estar entre '
        '${ProjectRules.spotsMin} y ${ProjectRules.spotsMax}';
  }

  final categoryError = _tagsError(
    draft.categories,
    max: ProjectRules.categoriesMax,
    emptyMessage: 'Elige al menos una categoría',
    tooManyMessage:
        'Elige como máximo ${ProjectRules.categoriesMax} categorías',
  );
  if (categoryError != null) errors[ProjectField.categories] = categoryError;

  final skillError = _tagsError(
    draft.skills,
    max: ProjectRules.skillsMax,
    emptyMessage: 'Agrega al menos una habilidad requerida',
    tooManyMessage: 'Agrega como máximo ${ProjectRules.skillsMax} habilidades',
  );
  if (skillError != null) errors[ProjectField.skills] = skillError;

  return errors;
}

String? _tagsError(
  List<String> tags, {
  required int max,
  required String emptyMessage,
  required String tooManyMessage,
}) {
  final normalized = tags.map(CatalogService.normalize).toSet();
  if (normalized.isEmpty) return emptyMessage;
  if (normalized.length > max) return tooManyMessage;
  for (final tag in normalized) {
    final error = CatalogService.validateName(tag);
    if (error != null) return '"$tag": $error';
  }
  return null;
}
