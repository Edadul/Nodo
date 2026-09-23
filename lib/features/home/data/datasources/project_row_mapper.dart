import '../../../../core/db/row_parsing.dart';
import '../../domain/entities/idea.dart';

/// Convierte filas de `projects` en [Idea]. Compartido por los datasources que
/// necesitan leer un proyecto (feed, postulaciones, administración).
abstract final class ProjectRowMapper {
  static const defaultGradients = [
    [0xFF7B6CF0, 0xFFB8A9FF],
    [0xFF4A3CC7, 0xFF7A6BE8],
    [0xFF6A5AE0, 0xFF9B8CF5],
    [0xFF553ECF, 0xFF8E7DF0],
  ];

  static Idea fromRow(
    Map<String, dynamic> row, {
    List<String> categories = const [],
    List<String> skills = const [],
  }) {
    final id = RowParsing.schemaId(row);
    return Idea(
      id: id,
      recordId: RowParsing.recordId(row),
      title: RowParsing.text(row['title']) ?? 'Proyecto sin título',
      description: RowParsing.text(row['description']) ?? '',
      categories: categories,
      skills: skills,
      filledSpots: RowParsing.integer(row['filled_spots']),
      totalSpots: RowParsing.integer(row['total_spots'], fallback: 1),
      creatorId: RowParsing.text(row['creator_id']) ?? '',
      createdAt: RowParsing.dateTime(row['created_at']),
      gradientColors: RowParsing.colors(row['gradient_colors']) ??
          defaultGradients[id.hashCode.abs() % defaultGradients.length],
    );
  }
}
