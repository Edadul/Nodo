import 'applicant_status.dart';

/// Entidad de dominio: postulante a un proyecto, vista desde el rol admin.
/// Sin dependencias de Flutter/UI.
class Applicant {
  const Applicant({
    required this.id,
    required this.projectId,
    required this.name,
    required this.program,
    required this.university,
    required this.motivation,
    required this.skills,
    required this.status,
    required this.submittedAt,
    this.avatarUrl,
    this.attachmentName,
    this.attachmentSizeLabel,
  });

  final int id;
  final int projectId;
  final String name;

  /// Ej. "Estudiante de Biología, 4to semestre".
  final String program;
  final String university;
  final String motivation;
  final List<String> skills;
  final ApplicantStatus status;
  final DateTime submittedAt;
  final String? avatarUrl;
  final String? attachmentName;
  final String? attachmentSizeLabel;

  bool get hasAttachment => attachmentName != null && attachmentName!.isNotEmpty;

  Applicant copyWith({ApplicantStatus? status}) {
    return Applicant(
      id: id,
      projectId: projectId,
      name: name,
      program: program,
      university: university,
      motivation: motivation,
      skills: skills,
      status: status ?? this.status,
      submittedAt: submittedAt,
      avatarUrl: avatarUrl,
      attachmentName: attachmentName,
      attachmentSizeLabel: attachmentSizeLabel,
    );
  }
}
