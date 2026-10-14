import '../../../auth/domain/entities/user.dart';
import '../entities/project_status.dart';
import '../entities/project_update.dart';
import '../repositories/project_updates_repository.dart';

class PublishProjectUpdate {
  const PublishProjectUpdate(this._repository);

  final ProjectUpdatesRepository _repository;

  Future<ProjectUpdate> call({
    required String projectId,
    required User author,
    required String title,
    required String body,
    ProjectStatus? newStatus,
    String? projectRecordId,
  }) {
    return _repository.publishUpdate(
      projectId: projectId,
      author: author,
      title: title,
      body: body,
      newStatus: newStatus,
      projectRecordId: projectRecordId,
    );
  }
}
