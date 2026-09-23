import '../../../auth/domain/entities/user.dart';
import '../entities/application.dart';
import '../repositories/application_repository.dart';

class GetMyApplication {
  const GetMyApplication(this._repository);

  final ApplicationRepository _repository;

  /// Postulación del usuario al proyecto, o null (también en sesión pública).
  Future<Application?> call({required String projectId, required User? user}) {
    if (user == null || user.isGuest || user.id.isEmpty) {
      return Future.value(null);
    }
    return _repository.findApplication(projectId, user.id);
  }
}
