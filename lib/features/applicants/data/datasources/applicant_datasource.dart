import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';

/// Contrato de fuente de datos del feature Applicants (postulantes).
abstract class ApplicantDataSource {
  Future<Idea?> fetchProject(String projectId);

  Future<List<Applicant>> fetchApplicantsByProject(String projectId);

  Future<Applicant?> fetchApplicant(String applicationId);

  Future<void> updateApplicationStatus(
    String applicationRecordId,
    ApplicantStatus status,
  );

  Future<void> updateFilledSpots(String projectRecordId, int filledSpots);
}
