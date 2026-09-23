import '../repositories/project_creation_repository.dart';

class GetCatalogSuggestions {
  const GetCatalogSuggestions(this._repository);

  final ProjectCreationRepository _repository;

  Future<CatalogSuggestions> call() => _repository.getSuggestions();
}
