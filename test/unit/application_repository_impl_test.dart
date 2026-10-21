import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/application/data/repositories/application_repository_impl.dart';
import 'package:nodo/features/application/domain/entities/application.dart';
import 'package:test/test.dart';

import 'support/builders.dart';
import 'support/mocks.dart';

void main() {
  late MockApplicationDataSource dataSource;
  late ApplicationRepositoryImpl repository;

  setUp(() {
    dataSource = MockApplicationDataSource();
    repository = ApplicationRepositoryImpl(dataSource);
  });

  group('ApplicationRepositoryImpl.getProject', () {
    test('devuelve el proyecto encontrado', () async {
      final project = buildIdea();
      when(() => dataSource.fetchProject('project-1'))
          .thenAnswer((_) async => project);

      expect(await repository.getProject('project-1'), same(project));
    });

    test('devuelve null si el proyecto no existe', () async {
      when(() => dataSource.fetchProject('missing'))
          .thenAnswer((_) async => null);

      expect(await repository.getProject('missing'), isNull);
    });
  });

  group('ApplicationRepositoryImpl.findApplication', () {
    void stubApplications(List<Application> applications) {
      when(() => dataSource.fetchApplications(
            projectId: 'project-1',
            applicantId: 'user-1',
          )).thenAnswer((_) async => applications);
    }

    test('devuelve null si el usuario no se ha postulado', () async {
      stubApplications([]);

      expect(await repository.findApplication('project-1', 'user-1'), isNull);
    });

    test('devuelve la única postulación existente', () async {
      final application = buildApplication(id: 'a-1');
      stubApplications([application]);

      expect(
        await repository.findApplication('project-1', 'user-1'),
        same(application),
      );
    });

    test('con varias postulaciones devuelve la más reciente', () async {
      final oldest =
          buildApplication(id: 'a-1', submittedAt: DateTime(2026, 1, 1));
      final newest =
          buildApplication(id: 'a-2', submittedAt: DateTime(2026, 3, 1));
      final middle =
          buildApplication(id: 'a-3', submittedAt: DateTime(2026, 2, 1));
      stubApplications([oldest, newest, middle]);

      final result = await repository.findApplication('project-1', 'user-1');

      expect(result?.id, equals('a-2'));
    });
  });

  group('ApplicationRepositoryImpl.listByApplicant', () {
    test('devuelve las postulaciones del usuario', () async {
      final applications = [buildApplication(id: 'a-1')];
      when(() => dataSource.fetchApplicationsByApplicant('user-1'))
          .thenAnswer((_) async => applications);

      expect(await repository.listByApplicant('user-1'), equals(applications));
    });
  });

  group('ApplicationRepositoryImpl.submit', () {
    test('escribe la postulación en la API y devuelve la persistida', () async {
      final application = buildApplication();
      final applicant = buildUser();
      final persisted = buildApplication(id: 'a-new');
      when(() => dataSource.insertApplication(application, applicant))
          .thenAnswer((_) async => persisted);

      final result = await repository.submit(application, applicant);

      expect(result.id, equals('a-new'));
      verify(() => dataSource.insertApplication(application, applicant))
          .called(1);
    });

    test('propaga el error de escritura', () {
      final application = buildApplication();
      final applicant = buildUser();
      when(() => dataSource.insertApplication(application, applicant))
          .thenThrow(Exception('500'));

      expect(() => repository.submit(application, applicant), throwsException);
    });
  });
}
