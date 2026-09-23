import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/project_draft.dart';
import '../../domain/repositories/project_creation_repository.dart';
import '../datasources/project_creation_datasource.dart';

class ProjectCreationRepositoryImpl implements ProjectCreationRepository {
  const ProjectCreationRepositoryImpl(this._dataSource);

  final ProjectCreationDataSource _dataSource;

  static const _defaultCategories = [
    'TECNOLOGÍA',
    'DISEÑO',
    'SOCIAL',
    'NEGOCIOS',
    'CIENCIA',
    'ARTE',
  ];

  static const _defaultSkills = [
    'FLUTTER',
    'BACKEND',
    'DISEÑO UX/UI',
    'DATOS',
    'MARKETING',
    'GESTIÓN',
  ];

  @override
  Future<CatalogSuggestions> getSuggestions() async {
    final results = await Future.wait([
      _dataSource.fetchCategoryNames(),
      _dataSource.fetchSkillNames(),
    ]);
    return CatalogSuggestions(
      categories: _merge(_defaultCategories, results[0]),
      skills: _merge(_defaultSkills, results[1]),
    );
  }

  @override
  Future<bool> creatorHasTitle(String creatorId, String title) async {
    final wanted = title.trim().toLowerCase();
    final titles = await _dataSource.fetchTitlesByCreator(creatorId);
    return titles.any((existing) => existing.trim().toLowerCase() == wanted);
  }

  @override
  Future<Idea> create(ProjectDraft draft, User creator) {
    return _dataSource.insertProject(draft, creator);
  }

  List<String> _merge(List<String> defaults, List<String> stored) {
    return ({...defaults, ...stored}.toList()..sort());
  }
}
