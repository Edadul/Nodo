import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/project_draft.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/get_catalog_suggestions.dart';
import '../../domain/validation/project_draft_validator.dart';

enum CreateProjectStatus { idle, submitting, success, error }

class CreateProjectViewModel extends ChangeNotifier {
  CreateProjectViewModel({
    required CreateProject createProject,
    required GetCatalogSuggestions getSuggestions,
  })  : _createProject = createProject, // ignore: prefer_initializing_formals
        _getSuggestions = getSuggestions; // ignore: prefer_initializing_formals

  final CreateProject _createProject;
  final GetCatalogSuggestions _getSuggestions;

  CreateProjectStatus status = CreateProjectStatus.idle;
  String? errorMessage;
  Map<ProjectField, String> fieldErrors = const {};

  List<String> categorySuggestions = const [];
  List<String> skillSuggestions = const [];

  final Set<String> selectedCategories = {};
  final Set<String> selectedSkills = {};
  int totalSpots = 3;

  bool _disposed = false;

  bool get isSubmitting => status == CreateProjectStatus.submitting;

  Future<void> loadSuggestions() async {
    try {
      final suggestions = await _getSuggestions();
      categorySuggestions = suggestions.categories;
      skillSuggestions = suggestions.skills;
    } catch (_) {
      // Sin sugerencias el formulario sigue funcionando con etiquetas propias.
    }
    _notify();
  }

  void toggleCategory(String category) {
    _toggle(selectedCategories, category, ProjectRules.categoriesMax,
        ProjectField.categories, 'categorías');
  }

  void toggleSkill(String skill) {
    _toggle(selectedSkills, skill, ProjectRules.skillsMax, ProjectField.skills,
        'habilidades');
  }

  /// Agrega una categoría escrita a mano. Devuelve el error, o null si se
  /// agregó.
  String? addCategory(String value) => _addCustom(
        value,
        selectedCategories,
        ProjectRules.categoriesMax,
        ProjectField.categories,
        'categorías',
      );

  /// Agrega una habilidad escrita a mano. Devuelve el error, o null si se
  /// agregó.
  String? addSkill(String value) => _addCustom(
        value,
        selectedSkills,
        ProjectRules.skillsMax,
        ProjectField.skills,
        'habilidades',
      );

  void setTotalSpots(int value) {
    totalSpots = value.clamp(ProjectRules.spotsMin, ProjectRules.spotsMax);
    _clearFieldError(ProjectField.totalSpots);
    _notify();
  }

  Future<Idea?> submit({
    required String title,
    required String description,
    required User? creator,
  }) async {
    final draft = ProjectDraft(
      title: title,
      description: description,
      totalSpots: totalSpots,
      categories: selectedCategories.toList(growable: false),
      skills: selectedSkills.toList(growable: false),
    );

    fieldErrors = validateProjectDraft(draft);
    if (fieldErrors.isNotEmpty) {
      status = CreateProjectStatus.error;
      errorMessage = 'Revisa los campos marcados';
      _notify();
      return null;
    }

    status = CreateProjectStatus.submitting;
    errorMessage = null;
    _notify();

    try {
      final idea = await _createProject(draft, creator: creator);
      status = CreateProjectStatus.success;
      _notify();
      return idea;
    } catch (error) {
      status = CreateProjectStatus.error;
      errorMessage = friendlyErrorMessage(error);
      _notify();
      return null;
    }
  }

  void clearFieldError(ProjectField field) {
    if (!fieldErrors.containsKey(field)) return;
    _clearFieldError(field);
    _notify();
  }

  void _toggle(
    Set<String> target,
    String value,
    int max,
    ProjectField field,
    String label,
  ) {
    final normalized = CatalogService.normalize(value);
    if (target.remove(normalized)) {
      _clearFieldError(field);
    } else if (target.length >= max) {
      fieldErrors = {...fieldErrors, field: 'Máximo $max $label'};
    } else {
      target.add(normalized);
      _clearFieldError(field);
    }
    _notify();
  }

  String? _addCustom(
    String value,
    Set<String> target,
    int max,
    ProjectField field,
    String label,
  ) {
    final error = CatalogService.validateName(value);
    if (error != null) return error;
    final normalized = CatalogService.normalize(value);
    if (target.contains(normalized)) return 'Ya está agregada';
    if (target.length >= max) return 'Máximo $max $label';
    target.add(normalized);
    _clearFieldError(field);
    _notify();
    return null;
  }

  void _clearFieldError(ProjectField field) {
    if (fieldErrors.containsKey(field)) {
      fieldErrors = Map.of(fieldErrors)..remove(field);
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
