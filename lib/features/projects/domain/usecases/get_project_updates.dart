import '../entities/project_update.dart';
import '../repositories/project_updates_repository.dart';

class GetProjectUpdates {
  const GetProjectUpdates(this._repository);

  final ProjectUpdatesRepository _repository;

  Future<List<ProjectUpdate>> call(String projectId) =>
      _repository.getUpdates(projectId);
}
