import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/project_draft.dart';

/// Contrato de fuente de datos del feature ProjectCreation.
abstract class ProjectCreationDataSource {
  Future<List<String>> fetchCategoryNames();

  Future<List<String>> fetchSkillNames();

  Future<List<String>> fetchTitlesByCreator(String creatorId);

  Future<Idea> insertProject(ProjectDraft draft, User creator);
}
