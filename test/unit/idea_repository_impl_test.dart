import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:test/test.dart';

import 'support/builders.dart';
import 'support/mocks.dart';

void main() {
  late MockIdeaDataSource dataSource;
  late IdeaRepositoryImpl repository;

  setUp(() {
    dataSource = MockIdeaDataSource();
    repository = IdeaRepositoryImpl(dataSource);
  });

  group('IdeaRepositoryImpl.getIdeas', () {
    test('devuelve las ideas de la API sin filtro de categoría', () async {
      final ideas = [buildIdea(id: 'p-1'), buildIdea(id: 'p-2')];
      when(() => dataSource.fetchIdeas()).thenAnswer((_) async => ideas);

      final result = await repository.getIdeas();

      expect(result, equals(ideas));
      verify(() => dataSource.fetchIdeas()).called(1);
    });

    test('reenvía la categoría pedida al datasource', () async {
      when(() => dataSource.fetchIdeas(category: 'DISEÑO'))
          .thenAnswer((_) async => [buildIdea()]);

      final result = await repository.getIdeas(category: 'DISEÑO');

      expect(result, hasLength(1));
      verify(() => dataSource.fetchIdeas(category: 'DISEÑO')).called(1);
    });

    test('devuelve lista vacía cuando no hay ideas', () async {
      when(() => dataSource.fetchIdeas()).thenAnswer((_) async => []);

      expect(await repository.getIdeas(), isEmpty);
    });

    test('propaga los errores de la API', () {
      when(() => dataSource.fetchIdeas()).thenThrow(Exception('sin red'));

      expect(() => repository.getIdeas(), throwsException);
    });
  });

  group('IdeaRepositoryImpl.getCategories', () {
    test('devuelve las categorías del datasource', () async {
      when(() => dataSource.fetchCategories())
          .thenAnswer((_) async => ['TODAS', 'DISEÑO', 'SOCIAL']);

      final result = await repository.getCategories();

      expect(result, equals(['TODAS', 'DISEÑO', 'SOCIAL']));
    });
  });
}
