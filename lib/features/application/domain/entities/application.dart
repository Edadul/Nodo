/// Entidad de dominio: postulación de un estudiante a un proyecto.
/// Sin dependencias de Flutter/UI.
class Application {
  const Application({
    this.id,
    required this.projectId,
    required this.motivation,
    required this.skills,
    required this.experience,
    required this.submittedAt,
  });

  /// Id autogenerado por la BD (null antes de persistir).
  final int? id;
  final int projectId;
  final String motivation;
  final List<String> skills;
  final String experience;
  final DateTime submittedAt;
}