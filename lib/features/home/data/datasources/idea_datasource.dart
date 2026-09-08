import '../../domain/entities/idea.dart';

/// Contrato de fuente de datos del feature Home.
/// Aquí se enchufa mock, Hive, Supabase, etc.
abstract class IdeaDataSource {
  Future<List<Idea>> fetchIdeas({String? category});

  Future<List<String>> fetchCategories();

  Future<Idea> insertIdea(Idea idea);
}
