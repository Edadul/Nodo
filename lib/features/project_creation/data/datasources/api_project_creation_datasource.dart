import 'dart:math';

import '../../../../core/db/db_interface.dart';
import '../../../../core/db/row_parsing.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/utils/uuid.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/data/datasources/project_row_mapper.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/project_draft.dart';
import 'project_creation_datasource.dart';

class ApiProjectCreationDataSource implements ProjectCreationDataSource {
  ApiProjectCreationDataSource(this._database, this._catalog, this._profiles);

  final IDatabase _database;
  final CatalogService _catalog;
  final UserProfileService _profiles;

  @override
  Future<List<String>> fetchCategoryNames() async =>
      (await _catalog.readAll(CatalogTable.categories)).values.toList();

  @override
  Future<List<String>> fetchSkillNames() async =>
      (await _catalog.readAll(CatalogTable.skills)).values.toList();

  @override
  Future<List<String>> fetchTitlesByCreator(String creatorId) async {
    final rows =
        await _database.read('projects', filters: {'creator_id': creatorId});
    return rows
        .map((row) => RowParsing.text(row['title']))
        .whereType<String>()
        .toList(growable: false);
  }

  @override
  Future<Idea> insertProject(ProjectDraft draft, User creator) async {
    await _profiles.ensureProfile(creator);

    final gradients = ProjectRowMapper.defaultGradients;
    final data = <String, dynamic>{
      'id': generateUuidV4(),
      'creator_id': creator.id,
      'title': draft.title,
      'description': draft.description,
      'total_spots': draft.totalSpots,
      'filled_spots': 0,
      'gradient_colors': RowParsing.encodeColors(
        gradients[Random().nextInt(gradients.length)],
      ),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    final inserted = await _database.insert('projects', data);
    final row = {...data, ...inserted};

    try {
      for (final category in draft.categories) {
        final categoryId =
            await _catalog.ensure(CatalogTable.categories, category);
        await _database.insert('project_categories', {
          'project_id': data['id'],
          'category_id': categoryId,
        });
      }
      for (final skill in draft.skills) {
        final skillId = await _catalog.ensure(CatalogTable.skills, skill);
        await _database.insert('project_skills', {
          'project_id': data['id'],
          'skill_id': skillId,
        });
      }
    } catch (_) {
      // Sin categorías/habilidades el proyecto queda incompleto: se deshace.
      // ON DELETE CASCADE limpia las filas puente ya creadas.
      final recordId = RowParsing.text(inserted['_id']);
      if (recordId != null) {
        try {
          await _database.delete('projects', recordId);
        } catch (_) {
          // Se reporta el error original, no el del rollback.
        }
      }
      rethrow;
    }

    return ProjectRowMapper.fromRow(
      row,
      categories: draft.categories,
      skills: draft.skills,
    );
  }
}
