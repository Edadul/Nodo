import '../db/sqlite_database.dart';
import '../../features/home/data/datasources/idea_datasource.dart';
import '../../features/home/data/datasources/sqlite_idea_datasource.dart';
import '../../features/home/data/repositories/idea_repository_impl.dart';
import '../../features/home/domain/repositories/idea_repository.dart';
import '../../features/home/domain/usecases/get_categories.dart';
import '../../features/home/domain/usecases/get_ideas.dart';
import '../../features/home/presentation/viewmodels/home_view_model.dart';
import '../../features/application/data/datasources/application_datasource.dart';
import '../../features/application/data/datasources/sqlite_application_datasource.dart';
import '../../features/application/data/repositories/application_repository_impl.dart';
import '../../features/application/domain/repositories/application_repository.dart';
import '../../features/application/domain/usecases/submit_application.dart';
import '../../features/application/presentation/viewmodels/application_view_model.dart';

/// Contenedor de dependencias simple (sin paquetes externos).
/// Para cambiar de BD: registra otro [IdeaDataSource] en [init].
final class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  IdeaDataSource? _ideaDataSource;
  IdeaRepository? _ideaRepository;
  GetIdeas? _getIdeas;
  GetCategories? _getCategories;
  ApplicationDataSource? _applicationDataSource;
  ApplicationRepository? _applicationRepository;
  SubmitApplication? _submitApplication;

  IdeaDataSource get ideaDataSource => _require(_ideaDataSource, 'ideaDataSource');
  IdeaRepository get ideaRepository => _require(_ideaRepository, 'ideaRepository');
  GetIdeas get getIdeas => _require(_getIdeas, 'getIdeas');
  GetCategories get getCategories => _require(_getCategories, 'getCategories');
  ApplicationDataSource get applicationDataSource =>
      _require(_applicationDataSource, 'applicationDataSource');
  ApplicationRepository get applicationRepository =>
      _require(_applicationRepository, 'applicationRepository');
  SubmitApplication get submitApplication =>
      _require(_submitApplication, 'submitApplication');

  bool get isInitialized => _ideaRepository != null;

  void init({
    IdeaDataSource? ideaDataSourceOverride,
    ApplicationDataSource? applicationDataSourceOverride,
  }) {
    _ideaDataSource =
      ideaDataSourceOverride ?? SQLiteIdeaDataSource(SQLiteDatabase());
    _ideaRepository = IdeaRepositoryImpl(_ideaDataSource!);
    _getIdeas = GetIdeas(_ideaRepository!);
    _getCategories = GetCategories(_ideaRepository!);

    _applicationDataSource =
      applicationDataSourceOverride ??
      SQLiteApplicationDataSource(SQLiteDatabase());
    _applicationRepository = ApplicationRepositoryImpl(_applicationDataSource!);
    _submitApplication = SubmitApplication(_applicationRepository!);
  }

  /// Útil en tests para re-registrar dependencias.
  void reset() {
    _ideaDataSource = null;
    _ideaRepository = null;
    _getIdeas = null;
    _getCategories = null;
    _applicationDataSource = null;
    _applicationRepository = null;
    _submitApplication = null;
  }

  HomeViewModel createHomeViewModel() {
    return HomeViewModel(
      getIdeas: getIdeas,
      getCategories: getCategories,
    );
  }

  ApplicationViewModel createApplicationViewModel() {
    return ApplicationViewModel(submitApplication: submitApplication);
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
