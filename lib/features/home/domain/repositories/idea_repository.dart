import '../entities/idea.dart';

/// Contrato del feature Home.
/// Cualquier fuente (mock, Hive, Supabase, etc.) implementa esto.
abstract class IdeaRepository {
  Future<List<Idea>> getIdeas({String? category});

  Future<List<String>> getCategories();

  Future<Idea> createIdea(Idea idea);
}
