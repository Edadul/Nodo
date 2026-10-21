import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/domain/entities/team_member.dart';
import 'package:test/test.dart';

import 'support/builders.dart';
import 'support/mocks.dart';

void main() {
  late MockApplicantDataSource dataSource;
  late ApplicantRepositoryImpl repository;

  setUp(() {
    dataSource = MockApplicantDataSource();
    repository = ApplicantRepositoryImpl(dataSource);
  });

  group('ApplicantRepositoryImpl lecturas', () {
    test('getProject devuelve el proyecto o null', () async {
      final project = buildIdea();
      when(() => dataSource.fetchProject('project-1'))
          .thenAnswer((_) async => project);
      when(() => dataSource.fetchProject('missing'))
          .thenAnswer((_) async => null);

      expect(await repository.getProject('project-1'), same(project));
      expect(await repository.getProject('missing'), isNull);
    });

    test('getApplicantsByProject devuelve los postulantes del proyecto',
        () async {
      final applicants = [
        buildApplicant(id: 'a-1'),
        buildApplicant(id: 'a-2', status: ApplicantStatus.accepted),
      ];
      when(() => dataSource.fetchApplicantsByProject('project-1'))
          .thenAnswer((_) async => applicants);

      final result = await repository.getApplicantsByProject('project-1');

      expect(result, equals(applicants));
    });

    test('getApplicant devuelve null si la postulación no existe', () async {
      when(() => dataSource.fetchApplicant('missing'))
          .thenAnswer((_) async => null);

      expect(await repository.getApplicant('missing'), isNull);
    });

    test('getTeamMembers devuelve el equipo del proyecto', () async {
      final project = buildIdea();
      const team = [
        TeamMember(userId: 'creator-1', name: 'Luis', isCreator: true),
        TeamMember(userId: 'user-1', name: 'Ana', isCreator: false),
      ];
      when(() => dataSource.fetchTeamMembers(project))
          .thenAnswer((_) async => team);

      final result = await repository.getTeamMembers(project);

      expect(result, hasLength(2));
      expect(result.where((m) => m.isCreator), hasLength(1));
    });
  });

  group('ApplicantRepositoryImpl.setStatus', () {
    setUp(() {
      registerFallbackValue(ApplicantStatus.pending);
      when(() => dataSource.updateApplicationStatus(any(), any()))
          .thenAnswer((_) async {});
    });

    test('actualiza la decisión usando el _id del registro', () async {
      final applicant = buildApplicant(id: 'a-1', recordId: 'rec-a-1');

      await repository.setStatus(applicant, ApplicantStatus.accepted);

      verify(
        () => dataSource.updateApplicationStatus(
          'rec-a-1',
          ApplicantStatus.accepted,
        ),
      ).called(1);
    });

    test('permite rechazar una postulación', () async {
      final applicant = buildApplicant(recordId: 'rec-a-2');

      await repository.setStatus(applicant, ApplicantStatus.rejected);

      verify(
        () => dataSource.updateApplicationStatus(
          'rec-a-2',
          ApplicantStatus.rejected,
        ),
      ).called(1);
    });

    test('propaga el error de la API', () {
      when(() => dataSource.updateApplicationStatus(any(), any()))
          .thenThrow(Exception('403'));

      expect(
        () => repository.setStatus(buildApplicant(), ApplicantStatus.accepted),
        throwsException,
      );
    });
  });

  group('ApplicantRepositoryImpl.setFilledSpots', () {
    test('actualiza los cupos usando el _id del proyecto', () async {
      final project = buildIdea(recordId: 'rec-project-9');
      when(() => dataSource.updateFilledSpots('rec-project-9', 2))
          .thenAnswer((_) async {});

      await repository.setFilledSpots(project, 2);

      verify(() => dataSource.updateFilledSpots('rec-project-9', 2)).called(1);
    });
  });
}
