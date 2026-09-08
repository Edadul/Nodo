import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';
import '../datasources/idea_datasource.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  const IdeaRepositoryImpl(this._dataSource);

  final IdeaDataSource _dataSource;

  @override
  Future<List<Idea>> getIdeas({String? category}) {
    return _dataSource.fetchIdeas(category: category);
  }

  @override
  Future<List<String>> getCategories() => _dataSource.fetchCategories();

  @override
  Future<Idea> createIdea(Idea idea) => _dataSource.insertIdea(idea);
}
