import '../../../../core/db/db_interface.dart';

class UpdateProjectDetails {
  const UpdateProjectDetails(this._database);

  final IDatabase _database;

  Future<void> call({
    required String projectRecordId,
    required String title,
    required String description,
  }) {
    return _database.update('projects', projectRecordId, {
      'title': title.trim(),
      'description': description.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
