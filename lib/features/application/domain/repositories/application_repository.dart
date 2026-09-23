import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../entities/application.dart';

/// Contrato del feature Application (postulaciones).
abstract class ApplicationRepository {
  /// Estado actual del proyecto (cupos, creador), o null si no existe.
  Future<Idea?> getProject(String projectId);

  /// Postulación del usuario a ese proyecto, o null si no tiene.
  Future<Application?> findApplication(String projectId, String applicantId);

  Future<Application> submit(Application application, User applicant);
}
