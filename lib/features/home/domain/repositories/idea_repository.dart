import '../entities/idea.dart';

/// Contrato del feature Home (lectura del feed).
abstract class IdeaRepository {
  Future<List<Idea>> getIdeas({String? category});

  Future<List<String>> getCategories();
}
