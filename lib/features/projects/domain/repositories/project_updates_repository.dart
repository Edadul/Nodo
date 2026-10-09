import '../../../auth/domain/entities/user.dart';
import '../entities/project_status.dart';
import '../entities/project_update.dart';

abstract class ProjectUpdatesRepository {
  Future<List<ProjectUpdate>> getUpdates(String projectId);

  Future<ProjectUpdate> publishUpdate({
    required String projectId,
    required User author,
    required String title,
    required String body,
    ProjectStatus? newStatus,
    String? projectRecordId,
  });
}
