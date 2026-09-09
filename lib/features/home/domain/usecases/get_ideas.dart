import '../entities/idea.dart';
import '../repositories/idea_repository.dart';

class GetIdeas {
  const GetIdeas(this._repository);

  final IdeaRepository _repository;

  Future<List<Idea>> call({String? category}) {
    return _repository.getIdeas(category: category);
  }
}
