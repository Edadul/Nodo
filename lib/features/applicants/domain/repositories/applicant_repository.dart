import '../entities/applicant.dart';
import '../entities/applicant_status.dart';

/// Contrato del feature Applicants (postulantes, vista admin).
abstract class ApplicantRepository {
  Future<List<Applicant>> getApplicantsByProject(int projectId);

  Future<Applicant> updateStatus(int applicantId, ApplicantStatus status);
}
