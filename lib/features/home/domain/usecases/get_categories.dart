import '../repositories/idea_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final IdeaRepository _repository;

  Future<List<String>> call() => _repository.getCategories();
}
