/// Datos que el creador llena en el formulario, antes de persistir.
class ProjectDraft {
  const ProjectDraft({
    required this.title,
    required this.description,
    required this.totalSpots,
    required this.categories,
    required this.skills,
  });

  final String title;
  final String description;

  /// Cupos para colaboradores (el creador no ocupa cupo).
  final int totalSpots;
  final List<String> categories;
  final List<String> skills;
}
