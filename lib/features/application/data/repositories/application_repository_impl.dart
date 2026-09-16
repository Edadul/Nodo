import '../../domain/entities/application.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  const ApplicationRepositoryImpl(this._dataSource);

  final ApplicationDataSource _dataSource;

  @override
  Future<Application> submit(Application application) {
    return _dataSource.insertApplication(application);
  }
}