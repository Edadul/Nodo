import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../entities/project_draft.dart';

/// Nombres ya registrados en los catálogos, para sugerir en el formulario.
class CatalogSuggestions {
  const CatalogSuggestions({required this.categories, required this.skills});

  final List<String> categories;
  final List<String> skills;
}

abstract class ProjectCreationRepository {
  Future<CatalogSuggestions> getSuggestions();

  Future<bool> creatorHasTitle(String creatorId, String title);

  Future<Idea> create(ProjectDraft draft, User creator);
}
