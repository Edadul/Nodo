import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/core/errors/failures.dart';
import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/features/applicants/data/datasources/api_applicant_datasource.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/domain/usecases/decide_application.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';

import 'support/fake_database.dart';
import 'support/seed.dart';

void main() {
  late FakeDatabase db;
  late GetApplicants getApplicants;
  late DecideApplication decide;

  void build(FakeDatabase database) {
    db = database;
    final repository =
        ApplicantRepositoryImpl(ApiApplicantDataSource(db, CatalogService(db)));
    getApplicants = GetApplicants(repository);
    decide = DecideApplication(repository);
  }

  Map<String, dynamic> application(String id) =>
      db.rows('applications').firstWhere((row) => row['id'] == id);

  int filledSpots() => db.rows('projects').single['filled_spots'] as int;

  Future<ApplicationDecision> decideAs(
    User? actor,
    String applicationId,
    ApplicantStatus decision,
  ) {
    return decide(
      projectId: projectId,
      applicationId: applicationId,
      decision: decision,
      actor: actor,
    );
  }

  Matcher failsWith(String text) => throwsA(
        isA<ValidationFailure>().having((f) => f.message, 'message',
            contains(text)),
      );

  setUp(() => build(seededDatabase()));

  group('GetApplicants', () {
    test('une postulación, perfil y habilidades del postulante', () async {
      final result = await getApplicants(projectId: projectId, actor: creator);

      expect(result.project.title, 'Plataforma Nodo');
      expect(result.applicants, hasLength(2));
      // Más reciente primero.
      expect(result.applicants.first.name, otherUser.name);
      final luis = result.applicants.last;
      expect(luis.program, 'Ingeniería de Sistemas');
      expect(luis.university, 'Uninorte');
      expect(luis.skills, ['FLUTTER']);
      expect(luis.experience, '1 a 2 años');
    });

    test('solo el creador puede verlas', () async {
      await expectLater(
        getApplicants(projectId: projectId, actor: applicantUser),
        failsWith('Solo el creador'),
      );
      await expectLater(
        getApplicants(projectId: projectId, actor: guest),
        failsWith('Inicia sesión'),
      );
    });
  });

  group('DecideApplication', () {
    test('aceptar cambia el estado y ocupa un cupo', () async {
      final result =
          await decideAs(creator, 'a-luis', ApplicantStatus.accepted);

      expect(application('a-luis')['status'], 'accepted');
      expect(filledSpots(), 1);
      expect(result.project.filledSpots, 1);
      expect(result.applicant.status, ApplicantStatus.accepted);
    });

    test('rechazar no toca los cupos', () async {
      await decideAs(creator, 'a-luis', ApplicantStatus.rejected);

      expect(application('a-luis')['status'], 'rejected');
      expect(filledSpots(), 0);
    });

    test('solo el creador decide', () async {
      await expectLater(
        decideAs(applicantUser, 'a-sara', ApplicantStatus.accepted),
        failsWith('Solo el creador'),
      );
      await expectLater(
        decideAs(null, 'a-sara', ApplicantStatus.accepted),
        failsWith('Inicia sesión'),
      );
      expect(application('a-sara')['status'], 'pending');
    });

    test('solo se decide una vez', () async {
      await decideAs(creator, 'a-luis', ApplicantStatus.accepted);
      await expectLater(
        decideAs(creator, 'a-luis', ApplicantStatus.rejected),
        failsWith('ya fue resuelta'),
      );
      expect(filledSpots(), 1);
    });

    test('no acepta sin cupos, pero sí permite rechazar', () async {
      build(seededDatabase(filledSpots: 2, totalSpots: 2));

      await expectLater(
        decideAs(creator, 'a-luis', ApplicantStatus.accepted),
        failsWith('No quedan cupos'),
      );
      await decideAs(creator, 'a-luis', ApplicantStatus.rejected);
      expect(application('a-luis')['status'], 'rejected');
    });

    test('llenar el último cupo bloquea más aceptaciones', () async {
      build(seededDatabase(totalSpots: 1));

      await decideAs(creator, 'a-luis', ApplicantStatus.accepted);
      await expectLater(
        decideAs(creator, 'a-sara', ApplicantStatus.accepted),
        failsWith('No quedan cupos'),
      );
    });

    test('rechaza postulaciones de otro proyecto o inexistentes', () async {
      application('a-sara')['project_id'] = 'p-otro';
      await expectLater(
        decideAs(creator, 'a-sara', ApplicantStatus.accepted),
        failsWith('ya no existe'),
      );
      await expectLater(
        decideAs(creator, 'nope', ApplicantStatus.accepted),
        failsWith('ya no existe'),
      );
    });

    test('pending no es una decisión válida', () async {
      await expectLater(
        decideAs(creator, 'a-luis', ApplicantStatus.pending),
        failsWith('inválida'),
      );
    });

    test('si falla el cambio de estado se libera el cupo', () async {
      db.failWhen = (operation, table) =>
          operation == 'update' && table == 'applications';

      await expectLater(
        decideAs(creator, 'a-luis', ApplicantStatus.accepted),
        throwsA(isA<Exception>()),
      );
      expect(filledSpots(), 0);
      expect(application('a-luis')['status'], 'pending');
    });
  });
}
