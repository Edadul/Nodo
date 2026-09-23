import '../../../../core/errors/failures.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/application.dart';
import '../repositories/application_repository.dart';
import '../validation/application_rules.dart';

class SubmitApplication {
  const SubmitApplication(this._repository);

  final ApplicationRepository _repository;

  /// Valida reglas de formulario y de negocio y persiste la postulación.
  /// Lanza [ValidationFailure] si alguna no se cumple.
  Future<Application> call({
    required String projectId,
    required String motivation,
    required List<String> skills,
    required String experience,
    required User? applicant,
  }) async {
    if (applicant == null || applicant.isGuest || applicant.id.isEmpty) {
      throw const ValidationFailure(
        'Inicia sesión con tu cuenta para postularte.',
      );
    }

    final errors = validateApplicationForm(
      motivation: motivation,
      skills: skills,
      experience: experience,
    );
    if (errors.isNotEmpty) throw ValidationFailure(errors.values.first);

    // Se consulta el estado real: el que muestra la pantalla puede estar
    // desactualizado.
    final project = await _repository.getProject(projectId);
    if (project == null) {
      throw const ValidationFailure('El proyecto ya no existe.');
    }
    if (project.isCreatedBy(applicant.id)) {
      throw const ValidationFailure(
        'No puedes postularte a tu propio proyecto.',
      );
    }
    if (project.isFull) {
      throw const ValidationFailure('El proyecto ya no tiene cupos.');
    }

    final existing = await _repository.findApplication(projectId, applicant.id);
    if (existing != null) throw ValidationFailure(duplicateMessage(existing));

    return _repository.submit(
      Application(
        projectId: projectId,
        applicantId: applicant.id,
        motivation: motivation.trim(),
        skills: skills.map(CatalogService.normalize).toSet().toList(),
        experience: experience,
        submittedAt: DateTime.now(),
      ),
      applicant,
    );
  }

  static String duplicateMessage(Application existing) {
    switch (existing.status) {
      case ApplicantStatus.pending:
        return 'Ya tienes una postulación pendiente en este proyecto.';
      case ApplicantStatus.accepted:
        return 'Ya eres parte de este proyecto.';
      case ApplicantStatus.rejected:
        return 'Tu postulación a este proyecto fue rechazada.';
    }
  }
}
