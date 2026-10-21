import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/project_creation/data/repositories/project_creation_repository_impl.dart';
import 'package:test/test.dart';

import 'support/builders.dart';
import 'support/mocks.dart';

void main() {
  late MockProjectCreationDataSource dataSource;
  late ProjectCreationRepositoryImpl repository;

  setUp(() {
    dataSource = MockProjectCreationDataSource();
    repository = ProjectCreationRepositoryImpl(dataSource);
  });

  group('ProjectCreationRepositoryImpl.getSuggestions', () {
    test('sin datos guardados devuelve los valores por defecto ordenados',
        () async {
      when(() => dataSource.fetchCategoryNames()).thenAnswer((_) async => []);
      when(() => dataSource.fetchSkillNames()).thenAnswer((_) async => []);

      final result = await repository.getSuggestions();

      expect(
        result.categories,
        equals(['ARTE', 'CIENCIA', 'DISEÑO', 'NEGOCIOS', 'SOCIAL', 'TECNOLOGÍA']),
      );
      expect(
        result.skills,
        equals([
          'BACKEND',
          'DATOS',
          'DISEÑO UX/UI',
          'FLUTTER',
          'GESTIÓN',
          'MARKETING',
        ]),
      );
    });

    test('combina el catálogo con los valores por defecto sin duplicados',
        () async {
      when(() => dataSource.fetchCategoryNames())
          .thenAnswer((_) async => ['SALUD', 'ARTE']);
      when(() => dataSource.fetchSkillNames())
          .thenAnswer((_) async => ['PYTHON', 'FLUTTER']);

      final result = await repository.getSuggestions();

      expect(result.categories, contains('SALUD'));
      expect(result.categories.where((c) => c == 'ARTE'), hasLength(1));
      expect(result.categories, hasLength(7));
      expect(result.skills, contains('PYTHON'));
      expect(result.skills.where((s) => s == 'FLUTTER'), hasLength(1));
      expect(result.skills, hasLength(7));
    });

    test('devuelve las listas ordenadas alfabéticamente', () async {
      when(() => dataSource.fetchCategoryNames())
          .thenAnswer((_) async => ['ZOOLOGÍA', 'AGRO']);
      when(() => dataSource.fetchSkillNames()).thenAnswer((_) async => []);

      final result = await repository.getSuggestions();

      expect(result.categories.first, equals('AGRO'));
      expect(result.categories.last, equals('ZOOLOGÍA'));
      expect(result.categories, equals([...result.categories]..sort()));
    });

    test('propaga el error si falla el catálogo', () {
      when(() => dataSource.fetchCategoryNames())
          .thenAnswer((_) async => throw Exception('sin red'));
      when(() => dataSource.fetchSkillNames()).thenAnswer((_) async => []);

      expect(repository.getSuggestions(), throwsException);
    });
  });

  group('ProjectCreationRepositoryImpl.creatorHasTitle', () {
    setUp(() {
      when(() => dataSource.fetchTitlesByCreator('user-1'))
          .thenAnswer((_) async => ['App de Reciclaje', 'Huerta urbana']);
    });

    test('detecta un título repetido ignorando mayúsculas y espacios',
        () async {
      expect(
        await repository.creatorHasTitle('user-1', '  app de reciclaje '),
        isTrue,
      );
    });

    test('devuelve false para un título nuevo', () async {
      expect(
        await repository.creatorHasTitle('user-1', 'Biblioteca digital'),
        isFalse,
      );
    });

    test('no confunde coincidencias parciales con duplicados', () async {
      expect(await repository.creatorHasTitle('user-1', 'Huerta'), isFalse);
    });

    test('devuelve false si el creador no tiene proyectos', () async {
      when(() => dataSource.fetchTitlesByCreator('user-2'))
          .thenAnswer((_) async => []);

      expect(await repository.creatorHasTitle('user-2', 'Algo'), isFalse);
    });
  });

  group('ProjectCreationRepositoryImpl.create', () {
    test('escribe el borrador en la API y devuelve el proyecto creado',
        () async {
      final draft = buildDraft();
      final creator = buildUser();
      final created = buildIdea(title: draft.title);
      when(() => dataSource.insertProject(draft, creator))
          .thenAnswer((_) async => created);

      final result = await repository.create(draft, creator);

      expect(result, same(created));
      verify(() => dataSource.insertProject(draft, creator)).called(1);
    });

    test('propaga el error de escritura', () {
      final draft = buildDraft();
      final creator = buildUser();
      when(() => dataSource.insertProject(draft, creator))
          .thenThrow(Exception('500'));

      expect(() => repository.create(draft, creator), throwsException);
    });
  });
}
