import 'project_status.dart';

/// Actualización narrativa del proyecto (timeline vertical).
class ProjectUpdate {
  const ProjectUpdate({
    required this.id,
    required this.recordId,
    required this.projectId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.body,
    required this.createdAt,
    this.status,
  });

  final String id;
  final String recordId;
  final String projectId;
  final String authorId;
  final String authorName;
  final String title;
  final String body;
  final DateTime createdAt;

  /// Si la actualización cambió el estado del proyecto.
  final ProjectStatus? status;
}
