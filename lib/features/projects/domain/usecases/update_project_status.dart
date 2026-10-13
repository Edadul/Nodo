import '../../../../core/db/db_interface.dart';
import '../entities/project_status.dart';

class UpdateProjectStatus {
  const UpdateProjectStatus(this._database);

  final IDatabase _database;

  Future<void> call({
    required String projectRecordId,
    required ProjectStatus status,
  }) {
    return _database.update('projects', projectRecordId, {
      'status': status.storageValue,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
