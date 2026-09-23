import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../../domain/repositories/applicant_repository.dart';
import '../datasources/applicant_datasource.dart';

class ApplicantRepositoryImpl implements ApplicantRepository {
  const ApplicantRepositoryImpl(this._dataSource);

  final ApplicantDataSource _dataSource;

  @override
  Future<Idea?> getProject(String projectId) =>
      _dataSource.fetchProject(projectId);

  @override
  Future<List<Applicant>> getApplicantsByProject(String projectId) {
    return _dataSource.fetchApplicantsByProject(projectId);
  }

  @override
  Future<Applicant?> getApplicant(String applicationId) =>
      _dataSource.fetchApplicant(applicationId);

  @override
  Future<void> setStatus(Applicant applicant, ApplicantStatus status) {
    return _dataSource.updateApplicationStatus(applicant.recordId, status);
  }

  @override
  Future<void> setFilledSpots(Idea project, int filledSpots) {
    return _dataSource.updateFilledSpots(project.recordId, filledSpots);
  }
}
