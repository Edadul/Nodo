import '../../../applicants/domain/entities/applicant_status.dart';

/// Entidad de dominio: postulación de un estudiante a un proyecto.
/// Sin dependencias de Flutter/UI.
class Application {
  const Application({
    this.id,
    this.recordId,
    required this.projectId,
    required this.applicantId,
    required this.motivation,
    required this.skills,
    required this.experience,
    required this.submittedAt,
    this.status = ApplicantStatus.pending,
  });

  /// `applications.id` (UUID). Null antes de persistir.
  final String? id;

  /// `_id` de Roble.
  final String? recordId;
  final String projectId;

  /// FK → `users.id`.
  final String applicantId;
  final String motivation;

  /// Habilidades que aporta. Se guardan en `user_skills` del postulante.
  final List<String> skills;
  final String experience;
  final DateTime submittedAt;
  final ApplicantStatus status;
}
