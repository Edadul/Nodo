import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/projects/data/repositories/project_updates_repository_impl.dart';
import 'package:nodo/features/projects/domain/entities/project_status.dart';
import 'package:test/test.dart';

import 'support/builders.dart';
import 'support/mocks.dart';

void main() {
  late MockProjectUpdatesDataSource dataSource;
  late ProjectUpdatesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(buildUser());
  });

  setUp(() {
    dataSource = MockProjectUpdatesDataSource();
    repository = ProjectUpdatesRepositoryImpl(dataSource);
  });

  group('ProjectUpdatesRepositoryImpl.getUpdates', () {
    test('devuelve el timeline del proyecto en el orden de la API', () async {
      final updates = [
        buildUpdate(id: 'u-2', title: 'Segundo'),
        buildUpdate(id: 'u-1', title: 'Primero'),
      ];
      when(() => dataSource.fetchUpdates('project-1'))
          .thenAnswer((_) async => updates);

      final result = await repository.getUpdates('project-1');

      expect(result.map((u) => u.id), equals(['u-2', 'u-1']));
    });

    test('devuelve lista vacía si el proyecto no tiene avances', () async {
      when(() => dataSource.fetchUpdates('project-1'))
          .thenAnswer((_) async => []);

      expect(await repository.getUpdates('project-1'), isEmpty);
    });
  });

  group('ProjectUpdatesRepositoryImpl.publishUpdate', () {
    void stubInsert() {
      when(() => dataSource.insertUpdate(
            projectId: any(named: 'projectId'),
            author: any(named: 'author'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            newStatus: any(named: 'newStatus'),
            projectRecordId: any(named: 'projectRecordId'),
          )).thenAnswer((_) async => buildUpdate(id: 'u-new'));
    }

    test('reenvía todos los campos y el cambio de estado a la API', () async {
      stubInsert();
      final author = buildUser();

      final result = await repository.publishUpdate(
        projectId: 'project-1',
        author: author,
        title: 'Lanzamos la beta',
        body: 'Ya hay 10 usuarios probándola',
        newStatus: ProjectStatus.inProgress,
        projectRecordId: 'rec-project-1',
      );

      expect(result.id, equals('u-new'));
      verify(() => dataSource.insertUpdate(
            projectId: 'project-1',
            author: author,
            title: 'Lanzamos la beta',
            body: 'Ya hay 10 usuarios probándola',
            newStatus: ProjectStatus.inProgress,
            projectRecordId: 'rec-project-1',
          )).called(1);
    });

    test('sin cambio de estado envía newStatus y projectRecordId en null',
        () async {
      stubInsert();

      await repository.publishUpdate(
        projectId: 'project-1',
        author: buildUser(),
        title: 'Reunión semanal',
        body: 'Definimos tareas',
      );

      final captured = verify(() => dataSource.insertUpdate(
            projectId: any(named: 'projectId'),
            author: any(named: 'author'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            newStatus: captureAny(named: 'newStatus'),
            projectRecordId: captureAny(named: 'projectRecordId'),
          )).captured;
      expect(captured, equals([null, null]));
    });

    test('propaga el error de escritura', () {
      when(() => dataSource.insertUpdate(
            projectId: any(named: 'projectId'),
            author: any(named: 'author'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            newStatus: any(named: 'newStatus'),
            projectRecordId: any(named: 'projectRecordId'),
          )).thenThrow(Exception('500'));

      expect(
        () => repository.publishUpdate(
          projectId: 'project-1',
          author: buildUser(),
          title: 'Avance',
          body: 'Detalle',
        ),
        throwsException,
      );
    });
  });
}
