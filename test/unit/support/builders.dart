import 'package:nodo/features/applicants/domain/entities/applicant.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/application/domain/entities/application.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/project_creation/domain/entities/project_draft.dart';
import 'package:nodo/features/projects/domain/entities/project_update.dart';

/// Entidades de dominio con valores por defecto, para que cada prueba solo
/// declare lo que le importa.

User buildUser({String id = 'user-1', String name = 'Ana'}) =>
    User(id: id, name: name, email: '$id@nodo.test');

Idea buildIdea({
  String id = 'project-1',
  String recordId = 'rec-project-1',
  String title = 'App de reciclaje',
  int filledSpots = 1,
  int totalSpots = 3,
}) {
  return Idea(
    id: id,
    recordId: recordId,
    title: title,
    description: 'Descripción',
    categories: const ['TECNOLOGÍA'],
    skills: const ['FLUTTER'],
    filledSpots: filledSpots,
    totalSpots: totalSpots,
    gradientColors: const [0xFF7B6CF0, 0xFFB8A9FF],
    creatorId: 'creator-1',
  );
}

ProjectDraft buildDraft({String title = 'App de reciclaje'}) {
  return ProjectDraft(
    title: title,
    description: 'Descripción',
    totalSpots: 3,
    categories: const ['TECNOLOGÍA'],
    skills: const ['FLUTTER'],
  );
}

Application buildApplication({
  String? id,
  String projectId = 'project-1',
  String applicantId = 'user-1',
  DateTime? submittedAt,
}) {
  return Application(
    id: id,
    projectId: projectId,
    applicantId: applicantId,
    motivation: 'Quiero aportar',
    skills: const ['FLUTTER'],
    experience: 'Dos proyectos previos',
    submittedAt: submittedAt ?? DateTime(2026, 1, 1),
  );
}

Applicant buildApplicant({
  String id = 'application-1',
  String recordId = 'rec-application-1',
  String name = 'Ana',
  ApplicantStatus status = ApplicantStatus.pending,
}) {
  return Applicant(
    id: id,
    recordId: recordId,
    projectId: 'project-1',
    applicantId: 'user-1',
    name: name,
    program: 'Ingeniería de Sistemas',
    university: 'Universidad del Norte',
    motivation: 'Quiero aportar',
    skills: const ['FLUTTER'],
    status: status,
    submittedAt: DateTime(2026, 1, 1),
  );
}

ProjectUpdate buildUpdate({String id = 'update-1', String title = 'Avance'}) {
  return ProjectUpdate(
    id: id,
    recordId: 'rec-$id',
    projectId: 'project-1',
    authorId: 'user-1',
    authorName: 'Ana',
    title: title,
    body: 'Terminamos el prototipo',
    createdAt: DateTime(2026, 1, 1),
  );
}
