import '../../../../core/db/db_interface.dart';
import '../../../../core/db/row_parsing.dart';
import '../../../../core/utils/uuid.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/project_status.dart';
import '../../domain/entities/project_update.dart';

class ApiProjectUpdatesDataSource {
  ApiProjectUpdatesDataSource(this._database);

  final IDatabase _database;

  Future<List<ProjectUpdate>> fetchUpdates(String projectId) async {
    try {
      final rows = await _database.read(
        'project_updates',
        filters: {'project_id': projectId},
      );
      final updates = rows.map(_toUpdate).toList(growable: true);
      updates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return List.unmodifiable(updates);
    } catch (_) {
      // Tabla aún no creada en Roble: timeline vacío hasta el setup admin.
      return const [];
    }
  }

  Future<ProjectUpdate> insertUpdate({
    required String projectId,
    required User author,
    required String title,
    required String body,
    ProjectStatus? newStatus,
    String? projectRecordId,
  }) async {
    final data = <String, dynamic>{
      'id': generateUuidV4(),
      'project_id': projectId,
      'author_id': author.id,
      'author_name': author.name,
      'title': title.trim(),
      'body': body.trim(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
      if (newStatus != null) 'status': newStatus.storageValue,
    };

    final inserted = await _database.insert('project_updates', data);

    if (newStatus != null &&
        projectRecordId != null &&
        projectRecordId.isNotEmpty) {
      await _database.update('projects', projectRecordId, {
        'status': newStatus.storageValue,
      });
    }

    return _toUpdate({...data, ...inserted});
  }

  ProjectUpdate _toUpdate(Map<String, dynamic> row) {
    final statusRaw = RowParsing.text(row['status']);
    return ProjectUpdate(
      id: RowParsing.schemaId(row),
      recordId: RowParsing.recordId(row),
      projectId: RowParsing.text(row['project_id']) ?? '',
      authorId: RowParsing.text(row['author_id']) ?? '',
      authorName: RowParsing.text(row['author_name']) ?? 'Integrante',
      title: RowParsing.text(row['title']) ?? '',
      body: RowParsing.text(row['body']) ?? '',
      createdAt: RowParsing.dateTime(row['created_at']) ?? DateTime.now(),
      status: statusRaw == null ? null : ProjectStatus.fromStorage(statusRaw),
    );
  }
}
