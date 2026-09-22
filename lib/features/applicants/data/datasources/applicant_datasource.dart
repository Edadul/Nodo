import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';

/// Contrato de fuente de datos del feature Applicants (postulantes).
abstract class ApplicantDataSource {
  Future<List<Applicant>> fetchApplicantsByProject(int projectId);

  Future<Applicant> updateApplicantStatus(
    int applicantId,
    ApplicantStatus status,
  );
}
