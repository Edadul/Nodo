import '../../../home/domain/entities/idea.dart';
import '../entities/team_member.dart';
import '../repositories/applicant_repository.dart';

class ProjectTeam {
  const ProjectTeam({required this.project, required this.members});

  final Idea project;
  final List<TeamMember> members;
}

/// Equipo público del proyecto: creador + postulantes aceptados.
/// No expone postulaciones pendientes.
class GetProjectTeam {
  const GetProjectTeam(this._repository);

  final ApplicantRepository _repository;

  Future<ProjectTeam> call(String projectId) async {
    final project = await _repository.getProject(projectId);
    if (project == null) {
      return ProjectTeam(
        project: Idea(
          id: projectId,
          title: '',
          description: '',
          categories: const [],
          skills: const [],
          filledSpots: 0,
          totalSpots: 0,
          gradientColors: const [],
        ),
        members: const [],
      );
    }

    final members = await _repository.getTeamMembers(project);
    return ProjectTeam(project: project, members: members);
  }
}
