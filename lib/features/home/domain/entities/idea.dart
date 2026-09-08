/// Entidad de dominio: sin dependencias de Flutter/UI.
class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.filledSpots,
    required this.totalSpots,
    required this.gradientColors,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> skills;
  final int filledSpots;
  final int totalSpots;

  /// Colores ARGB del gradiente (presentación los convierte a [Color]).
  final List<int> gradientColors;

  String get spotsLabel => '$filledSpots de $totalSpots cupos';
}
