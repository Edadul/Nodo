import '../../../../core/db/db_interface.dart';
import '../../../../core/db/row_parsing.dart';
import '../../../../core/services/catalog_service.dart';
import '../../domain/entities/idea.dart';
import 'idea_datasource.dart';
import 'project_row_mapper.dart';

class ApiIdeaDataSource implements IdeaDataSource {
  ApiIdeaDataSource(this._database, this._catalog);

  final IDatabase _database;
  final CatalogService _catalog;

  static const allCategories = 'TODAS';

  @override
  Future<List<Idea>> fetchIdeas({String? category}) async {
    final results = await Future.wait([
      _database.read('projects'),
      _catalog.readAll(CatalogTable.categories),
      _database.read('project_categories'),
      _catalog.readAll(CatalogTable.skills),
      _database.read('project_skills'),
    ]);
    final projects = results[0] as List<Map<String, dynamic>>;
    final categoryNames = results[1] as Map<String, String>;
    final projectCategories = results[2] as List<Map<String, dynamic>>;
    final skillNames = results[3] as Map<String, String>;
    final projectSkills = results[4] as List<Map<String, dynamic>>;

    final categoriesByProject =
        _group(projectCategories, 'category_id', categoryNames);
    final skillsByProject = _group(projectSkills, 'skill_id', skillNames);

    final ideas = projects.map((row) {
      final id = RowParsing.schemaId(row);
      return ProjectRowMapper.fromRow(
        row,
        categories: categoriesByProject[id] ?? const [],
        skills: skillsByProject[id] ?? const [],
      );
    }).where((idea) {
      return category == null ||
          category == allCategories ||
          idea.categories.contains(category);
    }).toList();

    // Más recientes primero.
    ideas.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return List.unmodifiable(ideas);
  }

  @override
  Future<List<String>> fetchCategories() async {
    final names = (await _catalog.readAll(CatalogTable.categories))
        .values
        .toSet()
        .toList()
      ..sort();
    return [allCategories, ...names];
  }

  /// Agrupa una tabla puente (`project_id`, `<foreignKey>`) en
  /// `project_id → [nombres]`.
  Map<String, List<String>> _group(
    List<Map<String, dynamic>> links,
    String foreignKey,
    Map<String, String> names,
  ) {
    final grouped = <String, List<String>>{};
    for (final link in links) {
      final projectId = RowParsing.text(link['project_id']);
      final name = names[RowParsing.text(link[foreignKey])];
      if (projectId == null || name == null) continue;
      grouped.putIfAbsent(projectId, () => []).add(name);
    }
    for (final list in grouped.values) {
      list.sort();
    }
    return grouped;
  }
}
