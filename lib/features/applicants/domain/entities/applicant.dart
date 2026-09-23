import 'applicant_status.dart';

/// Entidad de dominio: postulación vista desde el rol admin (fila de
/// `applications` + perfil del postulante en `users`).
/// Sin dependencias de Flutter/UI.
class Applicant {
  const Applicant({
    required this.id,
    required this.projectId,
    required this.applicantId,
    required this.name,
    required this.program,
    required this.university,
    required this.motivation,
    required this.skills,
    required this.status,
    required this.submittedAt,
    this.recordId = '',
    this.experience = '',
    this.avatarUrl,
    this.attachmentName,
    this.attachmentSizeLabel,
    this.attachmentUrl,
  });

  /// `applications.id` (UUID).
  final String id;

  /// `_id` de Roble, necesario para actualizar el estado.
  final String recordId;
  final String projectId;

  /// FK → `users.id`.
  final String applicantId;
  final String name;

  /// Ej. "Estudiante de Biología, 4to semestre".
  final String program;
  final String university;
  final String motivation;
  final String experience;
  final List<String> skills;
  final ApplicantStatus status;
  final DateTime submittedAt;
  final String? avatarUrl;
  final String? attachmentName;
  final String? attachmentSizeLabel;
  final String? attachmentUrl;

  bool get hasAttachment => attachmentName != null && attachmentName!.isNotEmpty;

  bool get isPending => status == ApplicantStatus.pending;

  Applicant copyWith({ApplicantStatus? status}) {
    return Applicant(
      id: id,
      recordId: recordId,
      projectId: projectId,
      applicantId: applicantId,
      name: name,
      program: program,
      university: university,
      motivation: motivation,
      experience: experience,
      skills: skills,
      status: status ?? this.status,
      submittedAt: submittedAt,
      avatarUrl: avatarUrl,
      attachmentName: attachmentName,
      attachmentSizeLabel: attachmentSizeLabel,
      attachmentUrl: attachmentUrl,
    );
  }
}
