import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/application.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  const ApplicationRepositoryImpl(this._dataSource);

  final ApplicationDataSource _dataSource;

  @override
  Future<Idea?> getProject(String projectId) =>
      _dataSource.fetchProject(projectId);

  @override
  Future<Application?> findApplication(
    String projectId,
    String applicantId,
  ) async {
    final applications = await _dataSource.fetchApplications(
      projectId: projectId,
      applicantId: applicantId,
    );
    if (applications.isEmpty) return null;
    // Si hubiera varias, la más reciente manda.
    applications.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return applications.first;
  }

  @override
  Future<Application> submit(Application application, User applicant) {
    return _dataSource.insertApplication(application, applicant);
  }
}
