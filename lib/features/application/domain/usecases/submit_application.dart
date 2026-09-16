import '../entities/application.dart';
import '../repositories/application_repository.dart';

class SubmitApplication {
  const SubmitApplication(this._repository);

  final ApplicationRepository _repository;

  Future<Application> call(Application application) {
    return _repository.submit(application);
  }
}