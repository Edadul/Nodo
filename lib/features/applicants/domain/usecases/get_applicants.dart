import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../entities/applicant.dart';
import '../repositories/applicant_repository.dart';

class ProjectApplicants {
  const ProjectApplicants({required this.project, required this.applicants});

  final Idea project;
  final List<Applicant> applicants;
}

class GetApplicants {
  const GetApplicants(this._repository);

  final ApplicantRepository _repository;

  /// Solo el creador del proyecto puede ver sus postulaciones.
  Future<ProjectApplicants> call({
    required String projectId,
    required User? actor,
  }) async {
    final project = await ensureCreator(_repository, projectId, actor);
    final applicants = await _repository.getApplicantsByProject(projectId);
    return ProjectApplicants(project: project, applicants: applicants);
  }
}

/// Devuelve el proyecto si [actor] es su creador; si no, [ValidationFailure].
Future<Idea> ensureCreator(
  ApplicantRepository repository,
  String projectId,
  User? actor,
) async {
  if (actor == null || actor.isGuest || actor.id.isEmpty) {
    throw const ValidationFailure(
      'Inicia sesión con tu cuenta para gestionar postulaciones.',
    );
  }
  final project = await repository.getProject(projectId);
  if (project == null) {
    throw const ValidationFailure('El proyecto ya no existe.');
  }
  if (!project.isCreatedBy(actor.id)) {
    throw const ValidationFailure(
      'Solo el creador del proyecto puede gestionar sus postulaciones.',
    );
  }
  return project;
}
