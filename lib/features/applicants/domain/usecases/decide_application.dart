import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../entities/applicant.dart';
import '../entities/applicant_status.dart';
import '../repositories/applicant_repository.dart';
import 'get_applicants.dart';

class ApplicationDecision {
  const ApplicationDecision({required this.applicant, required this.project});

  final Applicant applicant;

  /// Proyecto con `filled_spots` ya actualizado.
  final Idea project;
}

class DecideApplication {
  const DecideApplication(this._repository);

  final ApplicantRepository _repository;

  /// Acepta o rechaza una postulación pendiente.
  ///
  /// Reglas: solo el creador decide, solo sobre postulaciones pendientes del
  /// mismo proyecto, y aceptar exige un cupo libre (ocupa uno).
  Future<ApplicationDecision> call({
    required String projectId,
    required String applicationId,
    required ApplicantStatus decision,
    required User? actor,
  }) async {
    if (decision == ApplicantStatus.pending) {
      throw const ValidationFailure('Decisión inválida.');
    }

    // Estado real desde la BD: otro dispositivo pudo cambiarlo.
    final project = await ensureCreator(_repository, projectId, actor);
    final applicant = await _repository.getApplicant(applicationId);
    if (applicant == null || applicant.projectId != project.id) {
      throw const ValidationFailure('La postulación ya no existe.');
    }
    if (!applicant.isPending) {
      throw const ValidationFailure('Esta postulación ya fue resuelta.');
    }

    if (decision == ApplicantStatus.rejected) {
      await _repository.setStatus(applicant, decision);
      return ApplicationDecision(
        applicant: applicant.copyWith(status: decision),
        project: project,
      );
    }

    if (project.isFull) {
      throw const ValidationFailure(
        'No quedan cupos disponibles en el proyecto.',
      );
    }

    // Se ocupa el cupo antes de aceptar: si falla lo segundo, se libera.
    final filledSpots = project.filledSpots + 1;
    await _repository.setFilledSpots(project, filledSpots);
    try {
      await _repository.setStatus(applicant, decision);
    } catch (_) {
      try {
        await _repository.setFilledSpots(project, project.filledSpots);
      } catch (_) {
        // Se reporta el error original, no el del rollback.
      }
      rethrow;
    }

    return ApplicationDecision(
      applicant: applicant.copyWith(status: decision),
      project: project.copyWith(filledSpots: filledSpots),
    );
  }
}
