import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../../domain/repositories/applicant_repository.dart';
import '../datasources/applicant_datasource.dart';

class ApplicantRepositoryImpl implements ApplicantRepository {
  const ApplicantRepositoryImpl(this._dataSource);

  final ApplicantDataSource _dataSource;

  @override
  Future<List<Applicant>> getApplicantsByProject(int projectId) {
    return _dataSource.fetchApplicantsByProject(projectId);
  }

  @override
  Future<Applicant> updateStatus(int applicantId, ApplicantStatus status) {
    return _dataSource.updateApplicantStatus(applicantId, status);
  }
}
