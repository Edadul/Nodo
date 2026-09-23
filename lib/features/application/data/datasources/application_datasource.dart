import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/application.dart';

/// Contrato de fuente de datos del feature Application (postulaciones).
abstract class ApplicationDataSource {
  Future<Idea?> fetchProject(String projectId);

  Future<List<Application>> fetchApplications({
    required String projectId,
    required String applicantId,
  });

  Future<Application> insertApplication(Application application, User applicant);
}
