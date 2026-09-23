import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/core/errors/failures.dart';
import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/core/services/user_profile_service.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/application/domain/entities/application.dart';
import 'package:nodo/features/application/data/datasources/api_application_datasource.dart';
import 'package:nodo/features/application/data/repositories/application_repository_impl.dart';
import 'package:nodo/features/application/domain/usecases/get_my_application.dart';
import 'package:nodo/features/application/domain/usecases/submit_application.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';

import 'support/fake_database.dart';
import 'support/seed.dart';

const newUser = User(id: 'u-new', name: 'Nueva Persona', email: 'nueva@uni.edu');

void main() {
  late FakeDatabase db;
  late SubmitApplication submit;
  late GetMyApplication getMine;

  void build(FakeDatabase database) {
    db = database;
    final repository = ApplicationRepositoryImpl(
      ApiApplicationDataSource(db, CatalogService(db), UserProfileService(db)),
    );
    submit = SubmitApplication(repository);
    getMine = GetMyApplication(repository);
  }

  Future<Application> apply({
    User? as = newUser,
    String project = projectId,
    String motivation = 'Quiero aportar con desarrollo móvil y pruebas.',
    List<String> skills = const ['flutter', 'testing'],
    String experience = '1 a 2 años',
  }) {
    return submit(
      projectId: project,
      motivation: motivation,
      skills: skills,
      experience: experience,
      applicant: as,
    );
  }

  Matcher failsWith(String text) => throwsA(
        isA<ValidationFailure>().having((f) => f.message, 'message',
            contains(text)),
      );

  setUp(() => build(seededDatabase()));

  test('guarda la postulación con FKs reales y estado pending', () async {
    final application = await apply();

    final row = db.rows('applications').last;
    expect(row['id'], application.id);
    expect(row['project_id'], projectId);
    expect(row['applicant_id'], newUser.id);
    expect(row['status'], 'pending');
    expect(row['submitted_at'], endsWith('Z'));
    expect(application.status, ApplicantStatus.pending);

    // FK applicant_id → users.id y habilidades en user_skills.
    expect(db.rows('users').map((u) => u['id']), contains(newUser.id));
    expect(
      db.rows('user_skills').where((l) => l['user_id'] == newUser.id),
      hasLength(2),
    );
    expect(db.rows('skills').map((s) => s['name']), contains('TESTING'));
  });

  test('no duplica habilidades que el usuario ya tenía', () async {
    // applicantUser ya tiene FLUTTER; se postula a un proyecto nuevo.
    db.rows('projects').add({
      '_id': 'rec-p2',
      'id': 'p-2',
      'creator_id': creator.id,
      'title': 'Otro',
      'total_spots': 3,
      'filled_spots': 0,
    });
    await apply(as: applicantUser, project: 'p-2', skills: const ['FLUTTER']);
    expect(
      db.rows('user_skills').where((l) => l['user_id'] == applicantUser.id),
      hasLength(1),
    );
  });

  test('exige sesión con cuenta propia', () async {
    await expectLater(apply(as: null), failsWith('Inicia sesión'));
    await expectLater(apply(as: guest), failsWith('Inicia sesión'));
  });

  test('valida el formulario', () async {
    await expectLater(apply(motivation: 'corto'), failsWith('20'));
    await expectLater(apply(skills: const []), failsWith('habilidad'));
    await expectLater(apply(experience: 'Mucha'), failsWith('experiencia'));
  });

  test('el creador no puede postularse a su proyecto', () async {
    await expectLater(apply(as: creator), failsWith('propio proyecto'));
  });

  test('no permite postular a proyecto inexistente o lleno', () async {
    await expectLater(apply(project: 'no-existe'), failsWith('ya no existe'));

    build(seededDatabase(filledSpots: 2, totalSpots: 2));
    await expectLater(apply(), failsWith('no tiene cupos'));
  });

  test('no permite postular dos veces', () async {
    await expectLater(apply(as: applicantUser), failsWith('pendiente'));

    await apply();
    await expectLater(apply(), failsWith('pendiente'));
    expect(
      db.rows('applications').where((a) => a['applicant_id'] == newUser.id),
      hasLength(1),
    );
  });

  test('tras una decisión el mensaje refleja el estado', () async {
    db.rows('applications').first['status'] = 'accepted';
    await expectLater(apply(as: applicantUser), failsWith('Ya eres parte'));

    db.rows('applications').first['status'] = 'rejected';
    await expectLater(apply(as: applicantUser), failsWith('rechazada'));
  });

  test('GetMyApplication devuelve la postulación propia', () async {
    expect(await getMine(projectId: projectId, user: guest), isNull);
    expect(await getMine(projectId: projectId, user: newUser), isNull);

    final mine = await getMine(projectId: projectId, user: applicantUser);
    expect(mine?.id, 'a-luis');
    expect(mine?.status, ApplicantStatus.pending);
  });
}
