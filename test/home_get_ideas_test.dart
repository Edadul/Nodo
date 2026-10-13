import 'package:flutter_test/flutter_test.dart';
import 'support/fake_idea_datasource.dart';
import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';

void main() {
  late GetIdeas getIdeas;

  setUp(() {
    final repository = IdeaRepositoryImpl(FakeIdeaDataSource());
    getIdeas = GetIdeas(repository);
  });

  test('GetIdeas sin categoría devuelve todas', () async {
    final ideas = await getIdeas();
    expect(ideas.length, 5);
  });

  test('GetIdeas filtra por categoría', () async {
    final ideas = await getIdeas(category: 'TECNOLOGÍA');
    expect(ideas, hasLength(1));
    expect(ideas.first.title, 'Asistente de estudio con IA');
  });
}
