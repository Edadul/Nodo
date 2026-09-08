import '../../features/home/data/datasources/idea_datasource.dart';
import '../../features/home/data/datasources/mock_idea_datasource.dart';
import '../../features/home/data/repositories/idea_repository_impl.dart';
import '../../features/home/domain/repositories/idea_repository.dart';
import '../../features/home/domain/usecases/get_categories.dart';
import '../../features/home/domain/usecases/get_ideas.dart';
import '../../features/home/presentation/viewmodels/home_view_model.dart';

/// Contenedor de dependencias simple (sin paquetes externos).
/// Para cambiar de BD: registra otro [IdeaDataSource] en [init].
final class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  IdeaDataSource? _ideaDataSource;
  IdeaRepository? _ideaRepository;
  GetIdeas? _getIdeas;
  GetCategories? _getCategories;

  IdeaDataSource get ideaDataSource => _require(_ideaDataSource, 'ideaDataSource');
  IdeaRepository get ideaRepository => _require(_ideaRepository, 'ideaRepository');
  GetIdeas get getIdeas => _require(_getIdeas, 'getIdeas');
  GetCategories get getCategories => _require(_getCategories, 'getCategories');

  bool get isInitialized => _ideaRepository != null;

  void init({IdeaDataSource? ideaDataSourceOverride}) {
    _ideaDataSource = ideaDataSourceOverride ?? MockIdeaDataSource();
    _ideaRepository = IdeaRepositoryImpl(_ideaDataSource!);
    _getIdeas = GetIdeas(_ideaRepository!);
    _getCategories = GetCategories(_ideaRepository!);
  }

  /// Útil en tests para re-registrar dependencias.
  void reset() {
    _ideaDataSource = null;
    _ideaRepository = null;
    _getIdeas = null;
    _getCategories = null;
  }

  HomeViewModel createHomeViewModel() {
    return HomeViewModel(
      getIdeas: getIdeas,
      getCategories: getCategories,
    );
  }

  T _require<T>(T? value, String name) {
    if (value == null) {
      throw StateError(
        'ServiceLocator no inicializado ($name). Llama init() primero.',
      );
    }
    return value;
  }
}
