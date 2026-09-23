import '../../domain/entities/idea.dart';

/// Contrato de fuente de datos del feature Home (lectura del feed).
abstract class IdeaDataSource {
  Future<List<Idea>> fetchIdeas({String? category});

  Future<List<String>> fetchCategories();
}
