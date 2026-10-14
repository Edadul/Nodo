import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/project_status.dart';
import '../../domain/entities/project_update.dart';
import '../../domain/repositories/project_updates_repository.dart';
import '../datasources/api_project_updates_datasource.dart';

class ProjectUpdatesRepositoryImpl implements ProjectUpdatesRepository {
  ProjectUpdatesRepositoryImpl(this._dataSource);

  final ApiProjectUpdatesDataSource _dataSource;

  @override
  Future<List<ProjectUpdate>> getUpdates(String projectId) =>
      _dataSource.fetchUpdates(projectId);

  @override
  Future<ProjectUpdate> publishUpdate({
    required String projectId,
    required User author,
    required String title,
    required String body,
    ProjectStatus? newStatus,
    String? projectRecordId,
  }) {
    return _dataSource.insertUpdate(
      projectId: projectId,
      author: author,
      title: title,
      body: body,
      newStatus: newStatus,
      projectRecordId: projectRecordId,
    );
  }
}
