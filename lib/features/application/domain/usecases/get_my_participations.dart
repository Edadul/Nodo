import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/usecases/get_ideas.dart';
import '../entities/project_participation.dart';
import '../repositories/application_repository.dart';

class GetMyParticipations {
  const GetMyParticipations(this._applications, this._getIdeas);

  final ApplicationRepository _applications;
  final GetIdeas _getIdeas;

  /// Proyectos donde [user] postuló (pendiente, aceptado o rechazado).
  Future<List<ProjectParticipation>> call(User? user) async {
    if (user == null || user.isGuest || user.id.isEmpty) {
      return const [];
    }

    final applications = await _applications.listByApplicant(user.id);
    if (applications.isEmpty) return const [];

    final ideas = await _getIdeas();
    final byId = {for (final idea in ideas) idea.id: idea};

    final items = <ProjectParticipation>[];
    for (final application in applications) {
      final project = byId[application.projectId];
      if (project == null) continue;
      // El creador ya ve su proyecto en "Creados".
      if (project.isCreatedBy(user.id)) continue;
      items.add(
        ProjectParticipation(project: project, application: application),
      );
    }

    items.sort((a, b) {
      final rank = _rank(a.status).compareTo(_rank(b.status));
      if (rank != 0) return rank;
      return b.application.submittedAt.compareTo(a.application.submittedAt);
    });
    return items;
  }

  int _rank(ApplicantStatus status) {
    switch (status) {
      case ApplicantStatus.accepted:
        return 0;
      case ApplicantStatus.pending:
        return 1;
      case ApplicantStatus.rejected:
        return 2;
    }
  }
}
