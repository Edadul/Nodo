import '../../../../core/db/db_interface.dart';
import '../../domain/entities/idea.dart';
import 'idea_datasource.dart';

class SQLiteIdeaDataSource implements IdeaDataSource {
  SQLiteIdeaDataSource(this._database);

  final IDatabase _database;

  static const _categories = ['TODAS'];
  static const _gradientColors = [
    [0xFF7B6CF0, 0xFFB8A9FF],
    [0xFF4A3CC7, 0xFF7A6BE8],
    [0xFF6A5AE0, 0xFF9B8CF5],
    [0xFF553ECF, 0xFF8E7DF0],
  ];

  @override
  Future<List<Idea>> fetchIdeas({String? category}) async {
    final rows = await _database.queryTable('projects');
    return rows.map(_toIdea).where((idea) {
      return category == null || category == 'TODAS' || idea.category == category;
    }).toList(growable: false);
  }

  @override
  Future<List<String>> fetchCategories() async {
    final rows = await _database.queryTable('projects');
    final categories = rows
        .map((row) => _text(row['category'], fallback: 'TECNOLOGÍA'))
        .toSet()
        .toList()
      ..sort();
    return [..._categories, ...categories];
  }

  @override
  Future<Idea> insertIdea(Idea idea) async {
    await _database.insertData('projects', {
      'title': idea.title,
      'description': idea.description,
      'required_skills': idea.skills.join(', '),
      'category': idea.category,
      'filled_spots': idea.filledSpots,
      'total_spots': idea.totalSpots,
    });
    return idea;
  }

  Idea _toIdea(Map<String, dynamic> row) {
    final id = row['id'];
    final colorIndex = (id is int ? id : int.tryParse('$id') ?? 0) %
        _gradientColors.length;
    return Idea(
      id: '$id',
      title: _text(row['title']),
      description: _text(row['description']),
      category: _text(row['category'], fallback: 'TECNOLOGÍA'),
      skills: _text(row['required_skills'])
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList(growable: false),
      filledSpots: _number(row['filled_spots']),
      totalSpots: _number(row['total_spots'], fallback: 5),
      gradientColors: _gradientColors[colorIndex],
    );
  }

  String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  int _number(Object? value, {int fallback = 0}) {
    return value is int ? value : int.tryParse('$value') ?? fallback;
  }
}