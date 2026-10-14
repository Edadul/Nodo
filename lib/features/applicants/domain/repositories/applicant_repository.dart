import '../../../home/domain/entities/idea.dart';
import '../entities/applicant.dart';
import '../entities/applicant_status.dart';
import '../entities/team_member.dart';

/// Contrato del feature Applicants (postulantes, vista admin).
abstract class ApplicantRepository {
  Future<Idea?> getProject(String projectId);

  Future<List<Applicant>> getApplicantsByProject(String projectId);

  Future<Applicant?> getApplicant(String applicationId);

  /// Creador + postulantes aceptados (sin pendientes ni rechazados).
  Future<List<TeamMember>> getTeamMembers(Idea project);

  Future<void> setStatus(Applicant applicant, ApplicantStatus status);

  Future<void> setFilledSpots(Idea project, int filledSpots);
}
