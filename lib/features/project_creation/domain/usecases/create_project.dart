import '../../../../core/errors/failures.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../entities/project_draft.dart';
import '../repositories/project_creation_repository.dart';
import '../validation/project_draft_validator.dart';

class CreateProject {
  const CreateProject(this._repository);

  final ProjectCreationRepository _repository;

  /// Valida y persiste el proyecto. Lanza [ValidationFailure] si alguna regla
  /// no se cumple.
  Future<Idea> call(ProjectDraft draft, {required User? creator}) async {
    if (creator == null || creator.isGuest || creator.id.isEmpty) {
      throw const ValidationFailure(
        'Inicia sesión con tu cuenta para crear un proyecto.',
      );
    }

    final errors = validateProjectDraft(draft);
    if (errors.isNotEmpty) throw ValidationFailure(errors.values.first);

    final normalized = ProjectDraft(
      title: draft.title.trim(),
      description: draft.description.trim(),
      totalSpots: draft.totalSpots,
      categories: draft.categories.map(CatalogService.normalize).toSet().toList(),
      skills: draft.skills.map(CatalogService.normalize).toSet().toList(),
    );

    if (await _repository.creatorHasTitle(creator.id, normalized.title)) {
      throw const ValidationFailure(
        'Ya tienes un proyecto con ese título. Elige otro.',
      );
    }

    return _repository.create(normalized, creator);
  }
}
