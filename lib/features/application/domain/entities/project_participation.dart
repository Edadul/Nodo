import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../home/domain/entities/idea.dart';
import 'application.dart';

/// Proyecto al que el usuario postuló, con el estado de su postulación.
class ProjectParticipation {
  const ProjectParticipation({
    required this.project,
    required this.application,
  });

  final Idea project;
  final Application application;

  ApplicantStatus get status => application.status;

  bool get isMember => status == ApplicantStatus.accepted;
}
