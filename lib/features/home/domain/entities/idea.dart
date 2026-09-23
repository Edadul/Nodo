/// Entidad de dominio: sin dependencias de Flutter/UI.
class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.skills,
    required this.filledSpots,
    required this.totalSpots,
    required this.gradientColors,
    this.recordId = '',
    this.creatorId = '',
    this.createdAt,
  });

  /// `projects.id` (UUID del schema), el que referencian las FKs.
  final String id;

  /// `_id` de Roble, necesario para actualizar la fila.
  final String recordId;
  final String title;
  final String description;

  /// Nombres de `categories` enlazados vía `project_categories`.
  final List<String> categories;

  /// Nombres de `skills` enlazados vía `project_skills`.
  final List<String> skills;
  final int filledSpots;
  final int totalSpots;

  /// Id del creador (FK → `users.id`).
  final String creatorId;
  final DateTime? createdAt;

  /// Colores ARGB del gradiente (presentación los convierte a [Color]).
  final List<int> gradientColors;

  /// Categoría principal, para las vistas que muestran una sola.
  String get category => categories.isEmpty ? 'GENERAL' : categories.first;

  int get availableSpots =>
      (totalSpots - filledSpots).clamp(0, totalSpots).toInt();

  bool get isFull => availableSpots == 0;

  bool isCreatedBy(String userId) => userId.isNotEmpty && creatorId == userId;

  String get spotsLabel => '$filledSpots de $totalSpots cupos';

  Idea copyWith({int? filledSpots}) {
    return Idea(
      id: id,
      recordId: recordId,
      title: title,
      description: description,
      categories: categories,
      skills: skills,
      filledSpots: filledSpots ?? this.filledSpots,
      totalSpots: totalSpots,
      gradientColors: gradientColors,
      creatorId: creatorId,
      createdAt: createdAt,
    );
  }
}
